from fastapi import APIRouter, Depends, HTTPException, status, File, UploadFile, Form
from sqlalchemy.ext.asyncio import AsyncSession
from typing import List, Optional
from jose import JWTError, jwt
import json

from database import get_db
from models.user import User
from models.receipt import Receipt
from models.group import Group
from schemas.receipt import ReceiptCreate, ReceiptResponse
from auth.jwt import SECRET_KEY, ALGORITHM
from routers.auth import oauth2_scheme
from utils.s3 import upload_file_to_s3

router = APIRouter()

async def get_current_user(
    token: str = Depends(oauth2_scheme),
    db: AsyncSession = Depends(get_db)
) -> User:
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get("sub")
        if username is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception
    
    result = await db.execute(
        "SELECT * FROM users WHERE username = :username",
        {"username": username}
    )
    user = result.first()
    if user is None:
        raise credentials_exception
    return user

@router.post("/", response_model=ReceiptResponse)
async def create_receipt(
    description: str = Form(...),
    amount: float = Form(...),
    group_id: int = Form(...),
    image: Optional[UploadFile] = File(None),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> ReceiptResponse:
    # Verify group exists and user has access
    result = await db.execute(
        "SELECT * FROM groups WHERE id = :group_id AND created_by = :user_id",
        {"group_id": group_id, "user_id": current_user.id}
    )
    group = result.first()
    if not group:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Group not found or access denied"
        )
    
    # Upload image if provided
    image_url = None
    if image:
        image_url = await upload_file_to_s3(image)
    
    # Create receipt
    db_receipt = Receipt(
        group_id=group_id,
        description=description,
        amount=amount,
        uploaded_by=current_user.id,
        image_url=image_url
    )
    db.add(db_receipt)
    await db.commit()
    await db.refresh(db_receipt)
    return db_receipt

@router.get("/", response_model=List[ReceiptResponse])
async def get_user_receipts(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> List[ReceiptResponse]:
    # Get all receipts from groups created by the user
    result = await db.execute("""
        SELECT r.* FROM receipts r
        JOIN groups g ON r.group_id = g.id
        WHERE g.created_by = :user_id
        ORDER BY r.created_at DESC
    """, {"user_id": current_user.id})
    receipts = result.all()
    return receipts 