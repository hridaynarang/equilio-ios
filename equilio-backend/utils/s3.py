import boto3
import os
from botocore.exceptions import ClientError
from fastapi import UploadFile, HTTPException
import magic
from typing import Optional
from dotenv import load_dotenv

load_dotenv()

# AWS Configuration
AWS_ACCESS_KEY_ID = os.getenv("AWS_ACCESS_KEY_ID")
AWS_SECRET_ACCESS_KEY = os.getenv("AWS_SECRET_ACCESS_KEY")
AWS_REGION = os.getenv("AWS_REGION", "us-east-1")
S3_BUCKET = os.getenv("S3_BUCKET")

# Initialize S3 client
s3_client = boto3.client(
    's3',
    aws_access_key_id=AWS_ACCESS_KEY_ID,
    aws_secret_access_key=AWS_SECRET_ACCESS_KEY,
    region_name=AWS_REGION
)

ALLOWED_MIME_TYPES = {
    'image/jpeg',
    'image/png',
    'image/gif',
    'image/webp'
}

async def upload_file_to_s3(file: UploadFile, folder: str = "receipts") -> Optional[str]:
    """
    Upload a file to S3 and return the URL
    """
    try:
        # Read file content
        contents = await file.read()
        
        # Check file type
        mime = magic.Magic(mime=True)
        file_type = mime.from_buffer(contents)
        
        if file_type not in ALLOWED_MIME_TYPES:
            raise HTTPException(
                status_code=400,
                detail=f"File type {file_type} not allowed. Allowed types: {', '.join(ALLOWED_MIME_TYPES)}"
            )
        
        # Generate unique filename
        file_extension = file.filename.split('.')[-1]
        unique_filename = f"{folder}/{os.urandom(8).hex()}.{file_extension}"
        
        # Upload to S3
        s3_client.put_object(
            Bucket=S3_BUCKET,
            Key=unique_filename,
            Body=contents,
            ContentType=file_type
        )
        
        # Generate URL
        url = f"https://{S3_BUCKET}.s3.{AWS_REGION}.amazonaws.com/{unique_filename}"
        return url
        
    except ClientError as e:
        raise HTTPException(
            status_code=500,
            detail=f"Failed to upload file to S3: {str(e)}"
        )
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"An error occurred: {str(e)}"
        ) 