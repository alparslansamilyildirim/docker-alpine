# Alpine Calculator

Bu küçük proje, bir Docker konteyneri içinde çalışan basit bir Bash scripti kullanarak satır bazında sayı toplamı hesaplar.

## İçerik
- `Dockerfile` - Alpine tabanlı bir görüntü oluşturur, `bash` ve `tzdata` paketlerini yükler, ve `calculate_sum.sh` scriptini container içine kopyalar.
- `calculate_sum.sh` - Girdi dosyası olarak `/data/numbers.txt` bekler, her satırdaki tamsayıları toplar ve sonuçları bir çıktı dosyasına yazar.
- `numbers.txt` - Örnek girdi dosyası (her satırda boşlukla ayrılmış tamsayılar).

## Ne yapar?
`calculate_sum.sh` şu adımları izler:
- Varsayılan giriş dosyası: `/data/numbers.txt` (host makinadan volume ile bağlanmış olmalıdır).
- Her satırı okur, satırdaki geçerli tamsayıları toplar (negatif sayılar dahil). Harf/boşluk/ondalık gibi tamsayı olmayan tokenlar atlanır.
- Elde edilen her satır toplamını yeni bir satır olarak çıktı dosyasına yazar.
- Çıktı dosyası adı: `<YYYY-MM-DD>_<HH:MM:SS>-v1.txt` (örnek: `2025-09-29_11:29:05-v1.txt`) ve `/data` dizinine yazılır.

Not: Dockerfile içinde `ENV TZ=Europe/Istanbul` ayarlanmıştır; script tarih/saat hesapları bu timezone ile yapılır.

## Dosya adı ve sürümleme davranışı
- Script dosya adı formatında saat diliminde iki nokta (`:`) karakterleri kullanır (örn. `11:29:05`). Bu repoda oluşturulan örnek çıktı dosyalarında da iki nokta görülebilir.
- Script içinde `version` değişkeni şu an sabit `1` olarak set ediliyor; yani aynı zaman damgasına sahip bir dosya varsa üzerine yazma (truncate) işlemi gerçekleşir. Eğer otomatik artırma (v1 -> v2 ...) isterseniz, script'e mevcut dosya kontrolü ve artırma mantığı eklenmelidir.

## Örnek girdi formatı
numbers.txt örneği:

```
15 23
42 18
7 91
...
```

Her satırda boşluklarla ayrılmış tamsayılar olmalıdır. Her satırın toplamı çıktı dosyasında karşılık gelen satıra yazılacaktır.

## Örnek kullanım
1) Projeyi build edin (Docker gerekli):

```bash
docker build -t alpine-calculator .
```

2) Mevcut dizindeki `numbers.txt` dosyasını container içinde `/data` olarak bağlayıp çalıştırın:

```bash
docker run --rm -v "$(pwd)":/data alpine-calculator
```

| | |
|-|-|
| `docker` | Docker CLI; konteynerlerle etkileşim aracı. |
| `run` | Yeni bir konteyner oluşturup çalıştırır. |
| `--rm` | Çalışma bitince konteyneri otomatik siler (temizlik için). |
| `-v` | Bind mount seçenek başlığı (host:path → container:path). |
| `"$(pwd)"` | Shell ile mevcut çalışma dizininin tam yolu; çift tırnak boşlukları güvenli geçirir. |
| `:/data` | Host yolunun container içindeki hedef dizini; burada script `/data/numbers.txt` okur/yazar. |
| `alpine-calculator` | Çalıştırılacak Docker image adı; image içindeki `CMD` çalıştırılır. |

Çalıştırma sonrası `$(pwd)` dizininde `YYYY-MM-DD_HH:MM:SS-v1.txt` şeklinde bir çıktı dosyası oluşacaktır. Bu dosyada her satır girdi dosyasındaki karşılık gelen satırın toplamını içerir.

## Özel durumlar / kenar durumlar
- Eğer `/data/numbers.txt` mevcut değilse, script boş bir çıktı dosyası oluşturur ve başarılı şekilde çıkar (exit 0).
- Girdi dosyasının son karakterinin newline olup olmaması, çıktı dosyasının son satırına ekstra newline eklenip eklenmeyeceğini etkiler. Script, girdinin son karakteri newline değilse son satıra ekstra newline eklemez.
- Script yalnızca tamsayıları (regex `^-?[0-9]+$`) toplar; ondalık ve diğer formatlar yoksayılır.

## Sorun giderme
- Eğer mount edilen dizinde dosya oluşmuyorsa, Docker'ın mount izinlerini kontrol edin (`docker run -v` kullandığınız dizine Docker'ın yazma izinine sahip olmalıdır).
> **Docker Desktop -> `Settings` -> `Resources` -> `File Sharing` -> `Browse` -> `Open` -> Add (`+`) -> `Apply`**
- Eğer tarih/saat beklediğinizden farklıysa, host makinadaki timezone ve container içi TZ (`ENV TZ`) ayarlarını kontrol edin.

## Lisans
Bu proje basit bir örnektir; ihtiyaçlarınıza göre kullanıp uyarlayabilirsiniz.
