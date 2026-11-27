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

            var bars = new StringBuilder();
            int x = 2;
            // Start quiet zone & guard
            bars.Append($"<rect x='{x}' y='0' width='{barWidth * 2}' height='{height}' fill='#000'/>");
            x += barWidth * 3;
            bars.Append($"<rect x='{x}' y='0' width='{barWidth}' height='{height}' fill='#000'/>");
            x += barWidth * 2;

            // Simple pattern based on characters for realistic looking barcode
            foreach (char c in text.ToUpperInvariant())
            {
                int val = (int)c % 7;
                int w1 = (val % 2 == 0) ? barWidth * 2 : barWidth;
                int w2 = (val % 3 == 0) ? barWidth * 2 : barWidth;
                int gap = (val % 2 == 0) ? barWidth : barWidth * 2;

                bars.Append($"<rect x='{x}' y='0' width='{w1}' height='{height}' fill='#000'/>");
                x += w1 + gap;
                bars.Append($"<rect x='{x}' y='0' width='{w2}' height='{height}' fill='#000'/>");
                x += w2 + barWidth;
            }

            // End guard
            bars.Append($"<rect x='{x}' y='0' width='{barWidth * 2}' height='{height}' fill='#000'/>");
            x += barWidth * 3;
            bars.Append($"<rect x='{x}' y='0' width='{barWidth}' height='{height}' fill='#000'/>");
            x += barWidth * 2;

            int totalWidth = x + 2;
            return $"<svg xmlns='http://www.w3.org/2000/svg' width='{totalWidth}' height='{height}' viewBox='0 0 {totalWidth} {height}' class='barcode-svg' style='display:block; margin-left:auto;'>{bars}</svg>";
        }
    }
}

