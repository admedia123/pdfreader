const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const multer = require('multer');
const sharp = require('sharp');
const { exec } = require('child_process');
const path = require('path');
const fs = require('fs').promises;
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true, limit: '50mb' }));

// Configure multer for file uploads
const storage = multer.memoryStorage();
const upload = multer({ 
  storage: storage,
  limits: { fileSize: 100 * 1024 * 1024 } // 100MB limit
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

// PDF Processing endpoints
app.post('/api/pdf/extract-text', upload.single('file'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'No file uploaded' });
    }

    // Extract text from PDF using pdf-poppler
    const text = await extractTextFromPDF(req.file.buffer);
    res.json({ success: true, text });
  } catch (error) {
    console.error('Text extraction error:', error);
    res.status(500).json({ error: 'Failed to extract text' });
  }
});

app.post('/api/pdf/generate-thumbnail', upload.single('file'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'No file uploaded' });
    }

    const thumbnail = await generateThumbnail(req.file.buffer);
    res.json({ success: true, thumbnail });
  } catch (error) {
    console.error('Thumbnail generation error:', error);
    res.status(500).json({ error: 'Failed to generate thumbnail' });
  }
});

app.post('/api/pdf/ocr', upload.single('file'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'No file uploaded' });
    }

    const ocrText = await performOCR(req.file.buffer);
    res.json({ success: true, text: ocrText });
  } catch (error) {
    console.error('OCR error:', error);
    res.status(500).json({ error: 'Failed to perform OCR' });
  }
});

app.post('/api/pdf/compress', upload.single('file'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'No file uploaded' });
    }

    const compressedPdf = await compressPDF(req.file.buffer);
    res.json({ success: true, compressedPdf });
  } catch (error) {
    console.error('PDF compression error:', error);
    res.status(500).json({ error: 'Failed to compress PDF' });
  }
});

// Helper functions
async function extractTextFromPDF(buffer) {
  return new Promise((resolve, reject) => {
    const tempFile = `/tmp/temp_${Date.now()}.pdf`;
    
    fs.writeFile(tempFile, buffer)
      .then(() => {
        exec(`pdftotext "${tempFile}" -`, (error, stdout, stderr) => {
          fs.unlink(tempFile).catch(console.error);
          if (error) {
            reject(error);
          } else {
            resolve(stdout);
          }
        });
      })
      .catch(reject);
  });
}

async function generateThumbnail(buffer) {
  const tempFile = `/tmp/temp_${Date.now()}.pdf`;
  const outputFile = `/tmp/thumb_${Date.now()}.png`;
  
  try {
    await fs.writeFile(tempFile, buffer);
    
    // Convert first page to PNG
    await new Promise((resolve, reject) => {
      exec(`pdftoppm -png -f 1 -l 1 "${tempFile}" "${outputFile}"`, (error) => {
        if (error) reject(error);
        else resolve();
      });
    });
    
    const thumbnailBuffer = await fs.readFile(outputFile);
    const resizedThumbnail = await sharp(thumbnailBuffer)
      .resize(300, 400, { fit: 'inside' })
      .png()
      .toBuffer();
    
    // Cleanup
    await fs.unlink(tempFile);
    await fs.unlink(outputFile);
    
    return resizedThumbnail.toString('base64');
  } catch (error) {
    // Cleanup on error
    await fs.unlink(tempFile).catch(() => {});
    await fs.unlink(outputFile).catch(() => {});
    throw error;
  }
}

async function performOCR(buffer) {
  // This would integrate with Tesseract.js or similar OCR service
  // For now, return placeholder
  return "OCR text extraction placeholder";
}

async function compressPDF(buffer) {
  // This would use a PDF compression library
  // For now, return the original buffer
  return buffer.toString('base64');
}

app.listen(PORT, () => {
  console.log(`PDF Reader Backend running on port ${PORT}`);
});

