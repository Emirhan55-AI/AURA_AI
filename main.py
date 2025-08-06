# -*- coding: utf-8 -*-
"""
Aura AI Backend - Kıyafet Analizi ve Kombin Önerisi Servisi
FastAPI kullanarak Google Gemini Pro Vision ve Supabase entegrasyonu ile kıyafet analizi ve kombin önerileri yapan API
"""

import os
import json
import io
from PIL import Image
from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.responses import JSONResponse
from dotenv import load_dotenv
import google.generativeai as genai
from supabase import create_client, Client
from pydantic import BaseModel

# .env dosyasından çevre değişkenlerini yükle
load_dotenv()

# Google API anahtarını al ve doğrula
GOOGLE_API_KEY = os.getenv("GOOGLE_API_KEY")
if not GOOGLE_API_KEY:
    raise ValueError("GOOGLE_API_KEY çevre değişkeni bulunamadı. Lütfen .env dosyasında tanımlayın.")

# Supabase yapılandırması
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")

# Supabase client'ını başlat (varsa)
supabase: Client = None
if SUPABASE_URL and SUPABASE_KEY and SUPABASE_URL != "your_supabase_url_here":
    try:
        supabase = create_client(SUPABASE_URL, SUPABASE_KEY)
        print("✅ Supabase bağlantısı başarılı")
    except Exception as e:
        print(f"⚠️ Supabase bağlantı hatası: {e}")
        print("📝 Lütfen .env dosyasında SUPABASE_URL ve SUPABASE_KEY değerlerini kontrol edin")
else:
    print("📝 Supabase ayarları bulunamadı. /get-recommendation endpoint'i çalışmayacak.")

# Google Gemini AI'yi yapılandır
genai.configure(api_key=GOOGLE_API_KEY)

# Gemini modellerini başlat
vision_model = genai.GenerativeModel('gemini-1.5-flash')  # Görsel analiz için
text_model = genai.GenerativeModel('gemini-1.5-flash')    # Metin tabanlı öneriler için

# Pydantic modelleri
class RecommendationRequest(BaseModel):
    user_id: str
    soru: str

# FastAPI uygulamasını oluştur
app = FastAPI(
    title="Aura AI Backend",
    description="Kıyafet fotoğraflarını analiz eden ve kombin önerileri yapan yapay zeka servisi",
    version="2.0.0"
)


@app.get("/")
async def root():
    """Ana sayfa endpoint'i - API'nin çalışıp çalışmadığını kontrol etmek için"""
    return {"message": "Aura AI Backend - Kıyafet Analizi Servisi Çalışıyor!"}


@app.post("/process-image/")
async def process_image(file: UploadFile = File(...)):
    """
    Yüklenen kıyafet fotoğrafını Google Gemini Pro Vision ile analiz eder
    
    Args:
        file (UploadFile): Analiz edilecek kıyafet fotoğrafı
        
    Returns:
        JSONResponse: Giysinin kategori, renk ve desen bilgilerini içeren JSON
        
    Raises:
        HTTPException: Geçersiz dosya formatı veya işleme hatası durumunda
    """
    
    try:
        # Dosya türü doğrulaması
        if not file.content_type or not file.content_type.startswith("image/"):
            raise HTTPException(
                status_code=400,
                detail="Lütfen geçerli bir resim dosyası yükleyin. Desteklenen formatlar: JPG, PNG, JPEG"
            )
        
        # Dosyayı byte olarak oku
        image_bytes = await file.read()
        
        # Bytes'ı PIL Image nesnesine dönüştür
        image = Image.open(io.BytesIO(image_bytes))
        
        # Gemini modeli için prompt oluştur
        prompt = """Bu resimdeki giysiyi analiz et. Giysinin kategorisini (örneğin: Gömlek, Pantolon, Elbise, Ceket), ana rengini (örneğin: Mavi, Kırmızı, Siyah) ve desenini (örneğin: Düz, Çizgili, Ekose, Çiçekli) belirle.

Cevabını, başka hiçbir açıklama veya metin eklemeden, SADECE aşağıdaki anahtarlara sahip bir JSON nesnesi olarak ver: {"kategori": "", "renk": "", "desen": ""}

Sakın cevabında json ... gibi markdown işaretlerini kullanma. Sadece ham JSON metnini döndür."""
        
        # Gemini modeline prompt ve resmi gönder
        response = vision_model.generate_content([prompt, image])
        
        # Modelden gelen cevabı al
        ai_response_text = response.text.strip()
        
        try:
            # AI cevabını JSON'a dönüştür
            analysis_result = json.loads(ai_response_text)
            
            # JSON'da gerekli anahtarların olup olmadığını kontrol et
            required_keys = ["kategori", "renk", "desen"]
            if not all(key in analysis_result for key in required_keys):
                raise ValueError("AI cevabında gerekli anahtarlar eksik")
            
            # Başarılı sonucu döndür
            return JSONResponse(
                status_code=200,
                content={
                    "success": True,
                    "data": analysis_result,
                    "message": "Kıyafet analizi başarıyla tamamlandı"
                }
            )
            
        except json.JSONDecodeError:
            # AI'den gelen cevap geçerli JSON değilse
            raise HTTPException(
                status_code=500,
                detail="Yapay zeka geçerli bir formatta cevap vermedi. Lütfen tekrar deneyin."
            )
        
        except ValueError as ve:
            # JSON anahtarları eksikse
            raise HTTPException(
                status_code=500,
                detail=f"Yapay zeka cevabında eksiklik var: {str(ve)}"
            )
    
    except HTTPException:
        # HTTPException'ları tekrar fırlat
        raise
    
    except Exception as e:
        # Beklenmedik hatalar için genel hata yönetimi
        raise HTTPException(
            status_code=500,
            detail=f"Resim işlenirken bir hata oluştu: {str(e)}"
        )


@app.post("/get-recommendation/")
async def get_recommendation(request: RecommendationRequest):
    """
    Kullanıcının gardırobundaki kıyafetlere göre kişiselleştirilmiş kombin önerisi oluşturur
    
    Args:
        request (RecommendationRequest): user_id ve soru bilgilerini içeren request body
        
    Returns:
        JSONResponse: AI'den gelen kombin önerisi
        
    Raises:
        HTTPException: Veritabanı hatası veya işleme hatası durumunda
    """
    
    try:
        # Supabase bağlantısını kontrol et
        if not supabase:
            raise HTTPException(
                status_code=503,
                detail="Supabase veritabanı bağlantısı yapılandırılmamış. Lütfen .env dosyasında SUPABASE_URL ve SUPABASE_KEY değerlerini ayarlayın."
            )
        
        # Supabase'den kullanıcının kıyafetlerini çek
        try:
            response = supabase.table("kiyafetler").select("*").eq("user_id", request.user_id).execute()
            user_clothes = response.data
        except Exception as e:
            raise HTTPException(
                status_code=500,
                detail=f"Veritabanı bağlantı hatası: {str(e)}"
            )
        
        # Gardırop metni oluştur
        if not user_clothes:
            gardirop_metni = "Kullanıcının gardırobunda henüz kayıtlı kıyafet bulunmuyor."
        else:
            gardirop_listesi = []
            for kiyafet in user_clothes:
                gardirop_listesi.append(
                    f"- Kategori: {kiyafet.get('kategori', 'Belirtilmemiş')}, "
                    f"Renk: {kiyafet.get('renk', 'Belirtilmemiş')}, "
                    f"Desen: {kiyafet.get('desen', 'Belirtilmemiş')}"
                )
            gardirop_metni = "\n".join(gardirop_listesi)
        
        # AI prompt'u hazırla
        prompt = f"""Sen, Aura adında sevecen, pozitif ve uzman bir moda asistanısın. Görevin, kullanıcının gardırobundaki mevcut kıyafetleri kullanarak ona harika kombin önerileri sunmak. Asla gardırobında olmayan bir parçayı önerme. Cevapların kısa, net ve ilham verici olsun.

İşte kullanıcının mevcut gardırobu:
{gardirop_metni}

İşte kullanıcının sorusu:
{request.soru}

Şimdi bu bilgilere göre bir kombin önerisi oluştur."""
        
        try:
            # Gemini metin modeline prompt'u gönder
            ai_response = text_model.generate_content(prompt)
            
            # Başarılı cevabı döndür
            return JSONResponse(
                status_code=200,
                content={
                    "success": True,
                    "cevap": ai_response.text,
                    "message": "Kombin önerisi başarıyla oluşturuldu"
                }
            )
            
        except Exception as e:
            raise HTTPException(
                status_code=500,
                detail=f"AI modeli ile iletişim hatası: {str(e)}"
            )
    
    except HTTPException:
        # HTTPException'ları tekrar fırlat
        raise
    
    except Exception as e:
        # Beklenmedik hatalar için genel hata yönetimi
        raise HTTPException(
            status_code=500,
            detail=f"Kombin önerisi oluşturulurken bir hata oluştu: {str(e)}"
        )


@app.get("/health")
async def health_check():
    """API sağlık kontrolü endpoint'i"""
    return {
        "status": "healthy",
        "service": "Aura AI Backend",
        "gemini_configured": bool(GOOGLE_API_KEY),
        "supabase_configured": bool(SUPABASE_URL and SUPABASE_KEY)
    }


if __name__ == "__main__":
    import uvicorn
    # Geliştirme ortamında sunucuyu başlat
    uvicorn.run(app, host="0.0.0.0", port=8000)
