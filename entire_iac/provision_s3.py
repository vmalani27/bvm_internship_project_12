import boto3
import os
import re

def provision_s3_bucket(bucket_name, region='us-east-1', folder_path=None):
    """
    Provisions an S3 bucket, uploads files to it, and returns the bucket URL.

    :param bucket_name: Name of the S3 bucket to create.
    :param region: AWS region where the bucket will be created.
    :param folder_path: Path to the folder containing files to upload.
    :return: URL of the S3 bucket or resource URLs if files exist.
    """
    # Validate bucket name
    if not re.match(r'^[a-z0-9.-]{3,63}$', bucket_name) or '..' in bucket_name or bucket_name.startswith('.') or bucket_name.endswith('.'):
        print("Error: Bucket name is invalid. Ensure it meets S3 naming requirements.")
        return None

    # Initialize S3 client
    s3 = boto3.client('s3', region_name=region)

    # Check if bucket exists
    try:
        s3.head_bucket(Bucket=bucket_name)
        print(f"Bucket '{bucket_name}' already exists.")

        # List existing files in the bucket
        existing_files = s3.list_objects_v2(Bucket=bucket_name)
        if 'Contents' in existing_files:
            print("Files already in the bucket:")
            for obj in existing_files['Contents']:
                file_url = f"https://{bucket_name}.s3.{region}.amazonaws.com/{obj['Key']}"
                print(file_url)
            return [f"https://{bucket_name}.s3.{region}.amazonaws.com/{obj['Key']}" for obj in existing_files['Contents']]
        else:
            print("Bucket exists but is empty.")
    except s3.exceptions.ClientError:
        # Create the S3 bucket if it doesn't exist
        try:
            if region == 'us-east-1':
                s3.create_bucket(Bucket=bucket_name)
            else:
                s3.create_bucket(
                    Bucket=bucket_name,
                    CreateBucketConfiguration={'LocationConstraint': region}
                )
            print(f"Bucket '{bucket_name}' created successfully.")
        except Exception as e:
            print(f"Error creating bucket: {e}")
            return None

    # Upload files to the bucket
    if folder_path and os.path.isdir(folder_path):
        for root, _, files in os.walk(folder_path):
            for file in files:
                file_path = os.path.join(root, file)
                object_name = os.path.relpath(file_path, folder_path).replace('\\', '/')  # Ensure correct path format for S3
                try:
                    s3.upload_file(file_path, bucket_name, object_name)
                    print(f"Uploaded {file_path} to {bucket_name}/{object_name}")
                except Exception as e:
                    print(f"Error uploading {file_path}: {e}")
    else:
        print("Error: Folder path is invalid or does not contain any files.")

    # Return the bucket URL
    bucket_url = f"http://{bucket_name}.s3-website-{region}.amazonaws.com"
    print(f"Bucket URL: {bucket_url}")
    return bucket_url

# Example usage
if __name__ == "__main__":
    bucket_name = "my-iac-docs"  # Ensure this meets S3 naming rules
    region = "us-east-1"
    folder_path = "./frontend_build"  # Replace with the path to your frontend build folder

    result = provision_s3_bucket(bucket_name, region, folder_path)
    if result:
        if isinstance(result, list):
            print("Existing resource URLs:")
            for url in result:
                print(url)
        else:
            print(f"Provisioned bucket is available at: {result}")