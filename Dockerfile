FROM python:3.8-slim

# Set the working directory
WORKDIR /app

# Copy the requirements file
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the application code
COPY . .

# Expose the necessary port (if needed)
EXPOSE 7860

# Command to run ComfyUI
CMD ["python", "app.py"]  # Adjust as needed based on your setup
