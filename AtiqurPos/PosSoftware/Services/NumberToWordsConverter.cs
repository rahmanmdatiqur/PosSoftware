using System.Globalization;

namespace PosSoftware.Services
{
    public static class NumberToWordsConverter
    {
        private static readonly string[] Ones = {
            "Zero", "One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine",
            "Ten", "Eleven", "Twelve", "Thirteen", "Fourteen", "Fifteen", "Sixteen", "Seventeen", "Eighteen", "Nineteen"
        };

        private static readonly string[] Tens = {
            "Zero", "Ten", "Twenty", "Thirty", "Forty", "Fifty", "Sixty", "Seventy", "Eighty", "Ninety"
        };

        public static string ConvertToWords(decimal amount, string currencyName = "Taka")
        {
            if (amount == 0) return $"Zero {currencyName} Only";

            long integerPart = (long)Math.Floor(amount);
            int decimalPart = (int)Math.Round((amount - integerPart) * 100);

            string words = ConvertIntegerToWords(integerPart);

            if (decimalPart > 0)
            {
                words += $" and {ConvertIntegerToWords(decimalPart)} Paisa";
            }

            return $"{words} {currencyName} Only".Trim();
        }

        private static string ConvertIntegerToWords(long number)
        {
            if (number == 0) return "Zero";
            if (number < 0) return "Minus " + ConvertIntegerToWords(Math.Abs(number));

            string words = "";

            if ((number / 10000000) > 0)
            {
                words += ConvertIntegerToWords(number / 10000000) + " Crore ";
                number %= 10000000;
            }

            if ((number / 100000) > 0)
            {
                words += ConvertIntegerToWords(number / 100000) + " Lakh ";
                number %= 100000;
            }

            if ((number / 1000) > 0)
            {
                words += ConvertIntegerToWords(number / 1000) + " Thousand ";
                number %= 1000;
            }

            if ((number / 100) > 0)
            {
                words += ConvertIntegerToWords(number / 100) + " Hundred ";
                number %= 100;
            }

            if (number > 0)
            {
                if (number < 20)
                {
                    words += Ones[number];
                }
                else
                {
                    words += Tens[number / 10];
                    if ((number % 10) > 0)
                        words += " " + Ones[number % 10];
                }
            }

            return words.Trim();
        }
    }
}

