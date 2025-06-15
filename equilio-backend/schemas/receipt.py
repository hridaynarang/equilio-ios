from pydantic import BaseModel, HttpUrl
from datetime import datetime
from typing import Optional
from .user import UserResponse
from .group import GroupResponse

class ReceiptBase(BaseModel):
    description: str
    amount: float
    group_id: int
    image_url: Optional[str] = None

class ReceiptCreate(ReceiptBase):
    pass

class ReceiptResponse(ReceiptBase):
    id: int
    uploaded_by: int
    created_at: datetime
    uploader: Optional[UserResponse] = None
    group: Optional[GroupResponse] = None

    class Config:
        from_attributes = True 