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
# Hata düzeltmesi için gerekli import, bu sefer doğru yerden yapılıyor.
from postgrest.client import APIClient

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
        # SON HATA DÜZELTMESİ: Render'daki proxy sorununu çözmek için doğru options yapısı.
        # Bu yapı, Supabase kütüphanesinin Render ortamıyla uyumlu çalışmasını sağlar.
        supabase = create_client(
            SUPABASE_URL,
            SUPABASE_KEY,
            options={
                "postgrest_client_options": APIClient(transport_options={"proxies": None})
            }
        )
        print("✅ Supabase bağlantısı başarılı")
    except Exception as e:
        print(f"⚠️ Supabase bağlantı hatası: {e}")
        print("📝 Lütfen .env dosyasında SUPABASE_URL ve SUPABASE_KEY değerlerini kontrol edin")
else:
    print("📝 Supabase ayarları bulunamadı. /get-recommendation endpoint'i çalışmayacak.")

# Google Gemini AI'yi yapılandır
genai.configure(api_key=GOOGLE_API_KEY)

# Gemini modellerini başlat
vision_model = genai.GenerativeModel('gemini-1.5-flash')
text_model = genai.GenerativeModel('gemini-1.5-flash')

# Pydantic modelleri
class RecommendationRequest(BaseModel):
    user_id: str
    soru: str

# FastAPI uygulamasını oluştur
app = FastAPI(
    title="Aura AI Backend",
    description="Kıyafet fotoğraflarını analiz eden ve kombin önerileri yapan yapay zeka servisi",
    version="6.0.0" # Zafer versiyonu!
)


@app.get("/")
async def root():
    return {"message": "Aura AI Backend - Kıyafet Analizi Servisi Çalışıyor!"}


@app.post("/process-image/")
async def process_image(file: UploadFile = File(...)):
    try:
        if not file.content_type or not file.content_type.startswith("image/"):
            raise HTTPException(
                status_code=400,
                detail="Lütfen geçerli bir resim dosyası yükleyin."
            )
        
        image_bytes = await file.read()
        image = Image.open(io.BytesIO(image_bytes))
        
        prompt = """Bu resimdeki giysiyi analiz et. Giysinin kategorisini (örneğin: Gömlek, Pantolon, Elbise, Ceket), ana rengini (örneğin: Mavi, Kırmızı, Siyah) ve desenini (örneğin: Düz, Çizgili, Ekose, Çiçekli) belirle.

Cevabını, başka hiçbir açıklama veya metin eklemeden, SADECE aşağıdaki anahtarlara sahip bir JSON nesnesi olarak ver: {"kategori": "", "renk": "", "desen": ""}

Sakın cevabında json ... gibi markdown işaretlerini kullanma. Sadece ham JSON metnini döndür."""
        
        response = vision_model.generate_content([prompt, image])
        ai_response_text = response.text.strip()
        
        try:
            analysis_result = json.loads(ai_response_text)
            required_keys = ["kategori", "renk", "desen"]
            if not all(key in analysis_result for key in required_keys):
                raise ValueError("AI cevabında gerekli anahtarlar eksik")
            
            return JSONResponse(
                status_code=200,
                content={
                    "success": True,
                    "data": analysis_result,
                    "message": "Kıyafet analizi başarıyla tamamlandı"
                }
            )
        except (json.JSONDecodeError, ValueError) as e:
            raise HTTPException(
                status_code=500,
                detail=f"Yapay zeka geçerli bir formatta cevap vermedi: {e}"
            )
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Resim işlenirken bir hata oluştu: {str(e)}"
        )


@app.post("/get-recommendation/")
async def get_recommendation(request: RecommendationRequest):
    try:
        if not supabase:
            raise HTTPException(
                status_code=503,
                detail="Supabase veritabanı bağlantısı yapılandırılmamış."
            )
        
        response = supabase.table("kiyafetler").select("*").eq("user_id", request.user_id).execute()
        user_clothes = response.data
        
        if not user_clothes:
            gardirop_metni = "Kullanıcının gardırobunda henüz kayıtlı kıyafet bulunmuyor."
        else:
            gardirop_listesi = [
                (f"- Kategori: {kiyafet.get('kategori', 'N/A')}, "
                 f"Renk: {kiyafet.get('renk', 'N/A')}, "
                 f"Desen: {kiyafet.get('desen', 'N/A')}")
                for kiyafet in user_clothes
            ]
            gardirop_metni = "\n".join(gardirop_listesi)
        
        prompt = f"""Sen, Aura adında sevecen, pozitif ve uzman bir moda asistanısın. Görevin, kullanıcının gardırobundaki mevcut kıyafetleri kullanarak ona harika kombin önerileri sunmak. Asla gardırobında olmayan bir parçayı önerme. Cevapların kısa, net ve ilham verici olsun.

İşte kullanıcının mevcut gardırobu:
{gardirop_metni}

İşte kullanıcının sorusu:
{request.soru}

Şimdi bu bilgilere göre bir kombin önerisi oluştur."""
        
        ai_response = text_model.generate_content(prompt)
        
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
            detail=f"Kombin önerisi oluşturulurken bir hata oluştu: {str(e)}"
        )
