# Use a lightweight Python image
FROM python:3.10-slim

# Set non-interactive installation
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=America/Los_Angeles

# Install essential packages
RUN apt-get update && apt-get install -y \
    git \
    build-essential libssl-dev zlib1g-dev \
    libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
    libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev \
    ffmpeg libsm6 libxext6 cmake \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /code

# Copy requirements file
COPY ./requirements.txt /code/requirements.txt

# Create a non-root user
RUN useradd -m -u 1000 user
USER user
ENV HOME=/home/user \
    PATH=/home/user/.local/bin:$PATH

# Install pyenv
RUN curl https://pyenv.run | bash
ENV PATH=$HOME/.pyenv/shims:$HOME/.pyenv/bin:$PATH

# Install Python
RUN pyenv install 3.10.12 && \
    pyenv global 3.10.12 && \
    pyenv rehash && \
    pip install --no-cache-dir --upgrade pip setuptools wheel && \
    pip install --no-cache-dir datasets huggingface-hub "protobuf<4" "click<8.1"

# Install Python dependencies
RUN pip install --no-cache-dir --upgrade -r /code/requirements.txt

# Set the working directory for ComfyUI
WORKDIR $HOME/app

# Clone the ComfyUI repository
RUN git clone https://github.com/comfyanonymous/ComfyUI . && \
    git checkout 39e75862b248a20e8233ccee743ba5b2e977cdcf && \
    pip install --no-cache-dir -r requirements.txt

# Download checkpoints and models (add your wget commands here)
RUN echo "Downloading checkpoints..."  
# Example:
# RUN wget -P /path/to/checkpoints https://example.com/model.ckpt

# Install custom nodes (add your installation commands here)
RUN echo "Installing custom nodes..." 
# Example:
# RUN git clone https://github.com/example/custom-nodes.git

# Command to run ComfyUI
CMD ["python", "main.py", "--listen", "0.0.0.0", "--port", "7860", "--output-directory", "${USE_PERSISTENT_DATA:+/data/}"]
