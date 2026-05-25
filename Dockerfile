FROM python:3.12-slim
WORKDIR /app
COPY app.py .
COPY requirements.txt .
RUN pip install -r requirements.txt --upgrade
RUN useradd -m myuser
EXPOSE 5000
USER myuser
CMD ["python", "app.py"]
