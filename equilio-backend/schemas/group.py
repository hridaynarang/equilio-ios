from pydantic import BaseModel
from datetime import datetime
from typing import Optional
from .user import UserResponse

class GroupBase(BaseModel):
    name: str

class GroupCreate(GroupBase):
    pass

class GroupResponse(GroupBase):
    id: int
    created_by: int
    created_at: datetime
    creator: Optional[UserResponse] = None

    class Config:
        from_attributes = True 