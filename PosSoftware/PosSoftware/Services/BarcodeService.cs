using System.Text;

namespace PosSoftware.Services
{
    public static class BarcodeService
    {
        /// <summary>
        /// Generates a clean vector SVG barcode representation for any text
        /// </summary>
        public static string GenerateSvgBarcode(string text, int height = 45, int barWidth = 2)
        {
            if (string.IsNullOrWhiteSpace(text)) text = "INV-0000";

            var sb = new StringBuilder();
            sb.Append($"<svg xmlns='http://www.w3.org/2000/svg' height='{height}' class='barcode-svg' style='display:inline-block; vertical-align:middle;'>");

            int x = 2;
            // Start quiet zone & guard
            sb.Append($"<rect x='{x}' y='0' width='{barWidth * 2}' height='{height}' fill='#000'/>");
            x += barWidth * 3;
            sb.Append($"<rect x='{x}' y='0' width='{barWidth}' height='{height}' fill='#000'/>");
            x += barWidth * 2;

            // Simple pattern based on characters for realistic looking barcode
            foreach (char c in text.ToUpperInvariant())
            {
                int val = (int)c % 7;
                int w1 = (val % 2 == 0) ? barWidth * 2 : barWidth;
                int w2 = (val % 3 == 0) ? barWidth * 2 : barWidth;
                int gap = (val % 2 == 0) ? barWidth : barWidth * 2;

                sb.Append($"<rect x='{x}' y='0' width='{w1}' height='{height}' fill='#000'/>");
                x += w1 + gap;
                sb.Append($"<rect x='{x}' y='0' width='{w2}' height='{height}' fill='#000'/>");
                x += w2 + barWidth;
            }

            // End guard
            sb.Append($"<rect x='{x}' y='0' width='{barWidth * 2}' height='{height}' fill='#000'/>");
            x += barWidth * 3;
            sb.Append($"<rect x='{x}' y='0' width='{barWidth}' height='{height}' fill='#000'/>");
            x += barWidth * 2;

            sb.Append("</svg>");
            return sb.ToString();
        }
    }
}

