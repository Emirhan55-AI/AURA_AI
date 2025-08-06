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
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv
import google.generativeai as genai
from supabase import create_client, Client
from pydantic import BaseModel
# Hatalı import satırı kaldırıldı.

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
        # Kod, en temiz ve basit başlatma yöntemine geri döndürüldü.
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
    version="7.0.0" # Final Fix
)

# Manuel CORS middleware
@app.middleware("http")
async def cors_handler(request, call_next):
    response = await call_next(request)
    response.headers["Access-Control-Allow-Origin"] = "*"
    response.headers["Access-Control-Allow-Methods"] = "GET, POST, PUT, DELETE, OPTIONS"
    response.headers["Access-Control-Allow-Headers"] = "Content-Type, Authorization, Accept, Origin, X-Requested-With"
    response.headers["Access-Control-Max-Age"] = "86400"
    return response


@app.get("/")
async def root():
    return {"message": "Aura AI Backend - Kıyafet Analizi Servisi Çalışıyor!"}


@app.options("/{path:path}")
async def options_handler(path: str):
    """Handle CORS preflight requests"""
    return JSONResponse(
        status_code=200,
        content={},
        headers={
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
            "Access-Control-Allow-Headers": "Content-Type, Authorization, Accept, Origin, X-Requested-With",
            "Access-Control-Max-Age": "86400"
        }
    )


@app.options("/{path:path}")
async def options_handler(path: str):
    """Handle OPTIONS requests for CORS preflight"""
    return JSONResponse(
        status_code=200,
        content={},
        headers={
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
            "Access-Control-Allow-Headers": "Content-Type, Authorization, Accept, Origin, X-Requested-With",
            "Access-Control-Max-Age": "86400"
        }
    )


@app.post("/process-image/")
async def process_image(file: UploadFile = File(...)):
    try:
        print(f"🔍 DEBUG: Received file - Content-Type: {file.content_type}, Size: {file.size if hasattr(file, 'size') else 'Unknown'}")
        
        if not file.content_type or not file.content_type.startswith("image/"):
            print(f"❌ DEBUG: Invalid content type: {file.content_type}")
            raise HTTPException(
                status_code=400,
                detail="Lütfen geçerli bir resim dosyası yükleyin."
            )
        
        print("🔍 DEBUG: Reading image bytes...")
        image_bytes = await file.read()
        print(f"🔍 DEBUG: Image bytes read successfully, length: {len(image_bytes)}")
        
        if len(image_bytes) == 0:
            print("❌ DEBUG: Empty image file")
            raise HTTPException(
                status_code=400,
                detail="Boş resim dosyası yüklendi."
            )
        
        print("🔍 DEBUG: Opening image with PIL...")
        image = Image.open(io.BytesIO(image_bytes))
        print(f"🔍 DEBUG: Image opened successfully - Format: {image.format}, Size: {image.size}, Mode: {image.mode}")
        
        # Resmi RGB moduna çevir (mobil uygulamalardan gelen resimler bazen farklı modlarda olabilir)
        if image.mode != 'RGB':
            print(f"🔍 DEBUG: Converting image from {image.mode} to RGB")
            image = image.convert('RGB')
        
        prompt = """Bu resimdeki giysiyi analiz et. Giysinin kategorisini (örneğin: Gömlek, Pantolon, Elbise, Ceket), ana rengini (örneğin: Mavi, Kırmızı, Siyah), desenini (örneğin: Düz, Çizgili, Ekose, Çiçekli), stilini (örneğin: Günlük, Resmi, Spor), mevsimini (örneğin: Yazlık, Kışlık, Mevsimlik) ve kumaşını (örneğin: Kot, Keten, Penye) belirle.

Cevabını, başka hiçbir açıklama veya metin eklemeden, SADECE aşağıdaki anahtarlara sahip bir JSON nesnesi olarak ver: {"kategori": "", "renk": "", "desen": "", "stil": "", "mevsim": "", "kumas": ""}

Sakın cevabında json ... gibi markdown işaretlerini kullanma. Sadece ham JSON metnini döndür."""
        
        print("🔍 DEBUG: Sending request to Gemini Vision...")
        response = vision_model.generate_content([prompt, image])
        print(f"🔍 DEBUG: Gemini response received, length: {len(response.text) if response.text else 0}")
        
        ai_response_text = response.text.strip()
        print(f"🔍 DEBUG: AI response text: {ai_response_text}")
        
        try:
            analysis_result = json.loads(ai_response_text)
            required_keys = ["kategori", "renk", "desen", "stil", "mevsim", "kumas"]
            if not all(key in analysis_result for key in required_keys):
                print(f"❌ DEBUG: Missing keys in AI response: {analysis_result}")
                raise ValueError("AI cevabında gerekli anahtarlar eksik")
            
            print("✅ DEBUG: Analysis completed successfully")
            return JSONResponse(
                status_code=200,
                content={
                    "success": True,
                    "data": analysis_result,
                    "message": "Kıyafet analizi başarıyla tamamlandı"
                },
                headers={
                    "Access-Control-Allow-Origin": "*",
                    "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
                    "Access-Control-Allow-Headers": "Content-Type, Authorization, Accept, Origin, X-Requested-With"
                }
            )
        except (json.JSONDecodeError, ValueError) as e:
            print(f"❌ DEBUG: JSON parsing error: {e}")
            print(f"❌ DEBUG: Raw AI response: {ai_response_text}")
            raise HTTPException(
                status_code=500,
                detail=f"Yapay zeka geçerli bir formatta cevap vermedi: {str(e)}"
            )
    except HTTPException:
        # HTTPException'ları olduğu gibi geçir
        raise
    except Exception as e:
        print(f"💥 DEBUG: Unexpected error: {type(e).__name__}: {str(e)}")
        import traceback
        print(f"💥 DEBUG: Traceback: {traceback.format_exc()}")
        raise HTTPException(
            status_code=500,
            detail=f"Resim işlenirken bir hata oluştu: {type(e).__name__}: {str(e)}"
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
                 f"Desen: {kiyafet.get('desen', 'N/A')}, "
                 f"Stil: {kiyafet.get('stil', 'N/A')}, "
                 f"Mevsim: {kiyafet.get('mevsim', 'N/A')}, "
                 f"Kumaş: {kiyafet.get('kumas', 'N/A')}")
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
            },
            headers={
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
                "Access-Control-Allow-Headers": "Content-Type, Authorization, Accept, Origin, X-Requested-With"
            }
        )
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Kombin önerisi oluşturulurken bir hata oluştu: {str(e)}"
        )
print("Server çalışıyor...")