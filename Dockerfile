FROM alpine:latest

# Gerekli paketleri yükle (bash + tzdata)
RUN apk add --no-cache bash tzdata

# Varsayılan saat dilimi ortam değişkeni
ENV TZ=Europe/Istanbul

# Çalışma dizini oluştur
WORKDIR /app

# Script'i container içine kopyala
COPY calculate_sum.sh /app/

# Script'e çalıştırma yetkisi ver ve zoneinfo'u ayarla
RUN chmod +x /app/calculate_sum.sh \
	&& cp /usr/share/zoneinfo/$TZ /etc/localtime \
	&& echo $TZ > /etc/timezone || true

# Container çalıştırıldığında script'i çalıştır
CMD ["/app/calculate_sum.sh"]