# Use an official Python runtime as a parent image
FROM python:3.9-slim@sha256:0b4b0801ae9ae61bb57bc738b1efbe4e16b927fd581774c8edfed90f0e0f01ad

# Set the working directory in the container
WORKDIR /usr/src/app

RUN groupadd -r runner && \
    useradd -m -r -g runner runner

# Copy the requirements file first to leverage Docker layer caching
RUN apt-get update && \
    apt-get install --no-install-recommends -y wget libpq-dev gcc g++ && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

# Install any needed packages specified in requirements.txt
# No need for --user since we'll ensure the runner user can access the installed packages globally
RUN pip install --no-cache-dir -r requirements.txt

# Copy the current directory contents into the container at /usr/src/app
COPY . .

# Correct ownership and permissions before switching to user, ensure runner has full access
RUN chown -R runner:runner /usr/src/app
# Make port 8001 available to the world outside this container
EXPOSE 8001

# Define environment variable
ENV PYTHONUNBUFFERED=1

# Run the application
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8001", "--reload"]
