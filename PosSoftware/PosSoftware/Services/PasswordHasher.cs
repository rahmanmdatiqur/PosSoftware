using System.Security.Cryptography;
using System.Text;

namespace PosSoftware.Services
{
    public static class PasswordHasher
    {
        public static (string hash, string salt) HashPassword(string password)
        {
            byte[] saltBytes = RandomNumberGenerator.GetBytes(16);
            string salt = Convert.ToBase64String(saltBytes);
            string hash = GenerateHash(password, salt);
            return (hash, salt);
        }

        public static bool VerifyPassword(string password, string storedHash, string storedSalt)
        {
            string computed = GenerateHash(password, storedSalt);
            return CryptographicOperations.FixedTimeEquals(
                Encoding.UTF8.GetBytes(computed),
                Encoding.UTF8.GetBytes(storedHash)
            );
        }

        private static string GenerateHash(string password, string salt)
        {
            using var sha = SHA256.Create();
            byte[] combined = Encoding.UTF8.GetBytes(password + salt + "PosSecSaltKey2026");
            byte[] hashBytes = sha.ComputeHash(combined);
            return Convert.ToBase64String(hashBytes);
        }
    }
}
