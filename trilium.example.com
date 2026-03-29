server {
    listen 80;
    server_name trilium.example.com;

    # Логирование
    access_log /var/log/nginx/trilium_access.log;
    error_log /var/log/nginx/trilium_error.log;

    # Увеличиваем лимит загрузки (для больших заметок и вложений)
    client_max_body_size 128M;

    location / {
        proxy_pass http://192.168.1.11:8080;
        
        # Стандартные заголовки
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # WebSocket
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        
        # Отключаем буферизацию для стриминга (опционально, но полезно для реаль-тайма)
        proxy_buffering off;

        # Таймауты
        proxy_read_timeout 86400s;
        proxy_send_timeout 86400s;
    }
}