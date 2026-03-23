using QRCoder;

namespace CuddleBear.Service
{
    public class QrService
    {
        public byte[] GenerateQr(string text)
        {
            QRCodeGenerator generator = new QRCodeGenerator();
            QRCodeData data = generator.CreateQrCode(text, QRCodeGenerator.ECCLevel.Q);

            PngByteQRCode qrCode = new PngByteQRCode(data);

            return qrCode.GetGraphic(20);
        }
    }
}
