using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using PosSoftware.Services;
using System.Security.Claims;

namespace PosSoftware.Filters
{
    [AttributeUsage(AttributeTargets.Class | AttributeTargets.Method, AllowMultiple = true)]
    public class AuthorizePermissionAttribute : TypeFilterAttribute
    {
        public AuthorizePermissionAttribute(string pageName, string permissionType = "View")
            : base(typeof(AuthorizePermissionFilter))
        {
            Arguments = new object[] { pageName, permissionType };
        }
    }

    public class AuthorizePermissionFilter : IAsyncAuthorizationFilter
    {
        private readonly string _pageName;
        private readonly string _permissionType;
        private readonly IPermissionService _permissionService;

        public AuthorizePermissionFilter(string pageName, string permissionType, IPermissionService permissionService)
        {
            _pageName = pageName;
            _permissionType = permissionType;
            _permissionService = permissionService;
        }

        public async Task OnAuthorizationAsync(AuthorizationFilterContext context)
        {
            var user = context.HttpContext.User;
            if (user == null || !user.Identity?.IsAuthenticated == true)
            {
                context.Result = new RedirectToActionResult("Login", "Account", new { returnUrl = context.HttpContext.Request.Path });
                return;
            }

            // 1. SuperAdmin has unrestricted access to all pages
            var roleNameClaim = user.FindFirst(ClaimTypes.Role)?.Value;
            if (roleNameClaim != null && roleNameClaim.Equals("SuperAdmin", StringComparison.OrdinalIgnoreCase))
            {
                return;
            }

            // 2. Extract numeric RoleId
            var roleIdClaim = user.FindFirst("RoleId")?.Value;
            if (string.IsNullOrEmpty(roleIdClaim) || !int.TryParse(roleIdClaim, out int roleId))
            {
                context.Result = new RedirectToActionResult("AccessDenied", "Account", null);
                return;
            }

            bool hasPerm = await _permissionService.HasPermissionAsync(roleId, _pageName, _permissionType);
            if (!hasPerm)
            {
                bool isAjax = context.HttpContext.Request.Headers["X-Requested-With"] == "XMLHttpRequest"
                    || context.HttpContext.Request.Headers["Accept"].ToString().Contains("application/json");

                if (isAjax)
                {
                    context.Result = new JsonResult(new { success = false, message = $"Access Denied: Missing {_permissionType} permission for {_pageName}." })
                    {
                        StatusCode = StatusCodes.Status403Forbidden
                    };
                }
                else
                {
                    context.Result = new RedirectToActionResult("AccessDenied", "Account", new { pageName = _pageName, actionType = _permissionType });
                }
            }
        }
    }
}
