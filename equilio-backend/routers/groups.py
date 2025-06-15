from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from typing import List
from jose import JWTError, jwt

from database import get_db
from models.user import User
from models.group import Group
from schemas.group import GroupCreate, GroupResponse
from auth.jwt import SECRET_KEY, ALGORITHM
from routers.auth import oauth2_scheme

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

@router.post("/", response_model=GroupResponse)
async def create_group(
    group: GroupCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> GroupResponse:
    db_group = Group(
        name=group.name,
        created_by=current_user.id
    )
    db.add(db_group)
    await db.commit()
    await db.refresh(db_group)
    return db_group

@router.get("/", response_model=List[GroupResponse])
async def get_user_groups(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
) -> List[GroupResponse]:
    result = await db.execute(
        "SELECT * FROM groups WHERE created_by = :user_id",
        {"user_id": current_user.id}
    )
    groups = result.all()
    return groups 