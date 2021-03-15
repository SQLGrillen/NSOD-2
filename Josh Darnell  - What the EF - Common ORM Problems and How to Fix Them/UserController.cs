using CommonOrmProblems.Web.Data;
using CommonOrmProblems.Web.Entities;
using CommonOrmProblems.Web.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore.Diagnostics;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Data.Common;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace CommonOrmProblems.Web.Controllers
{
    public class UserController : Controller
    {
        private readonly ILogger<UserController> _logger; 
        private readonly StackOverflowContext _context;

        public UserController(
            ILogger<UserController> logger,
            StackOverflowContext context)
        {
            _logger = logger;
            _context = context;
        }

        [HttpGet]
        public IActionResult ByReputationV1(int page)
        {
            int rowsPerPage = 20;

            var TenKRepUsers = _context.Users
                .Where(u => u.Reputation > 10000)
                .OrderByDescending(u => u.Reputation)
                .ToList();

            int startingUser = rowsPerPage * (page - 1);

            var models = new List<UserModel>();
            for (int i = startingUser; i < startingUser + rowsPerPage; i++)
            {
                models.Add(new UserModel
                {
                    DisplayName = TenKRepUsers[i].DisplayName,
                    Reputation = TenKRepUsers[i].Reputation
                });
            }

            return Ok(models);
        }

        [HttpGet]
        public IActionResult ByReputationV2(int page)
        {
            int rowsPerPage = 20;

            var models = _context.Users
                .Where(u => u.Reputation > 10000)
                .OrderByDescending(u => u.Reputation)
                .Skip((page - 1) * rowsPerPage) // Translates to OFFSET
                .Take(rowsPerPage) // Translates to FETCH
                .Select(u => new UserModel
                {
                    DisplayName = u.DisplayName,
                    Reputation = u.Reputation
                })
                .ToList();

            return Ok(models);
        }

        [HttpGet]
        public IActionResult JuneBirthdaysV1()
        {
            var count = _context.Users
                .Where(u => u.CreationDate.Month == 6)
                .Count();

            #region Better Code
            /*
            ALTER TABLE dbo.Users
            ADD BirthMonth AS DATEPART(month, CreationDate);
            GO

            CREATE NONCLUSTERED INDEX IX_BirthMonth
            ON dbo.Users (BirthMonth);
            GO
            */
            #endregion

            return Ok(count);
        }

        [HttpGet]
        public IActionResult UsersV1(string displayName)
        {
            var users = _context.Users
                .Where(u => u.DisplayName.ToUpper() == displayName.ToUpper())
                .Select(u => u.DisplayName)
                .ToList();

            #region Better Code
            /*
            CREATE NONCLUSTERED INDEX IX_DisplayName
            ON dbo.Users (DisplayName);
             */
            #endregion

            return Ok(users);
        }

        public IActionResult UsersV2(string displayName)
        {
            var users = _context.Users
                .Where(u => u.DisplayName == displayName)
                .Select(u => u.DisplayName)
                .ToList();

            return Ok(users);
        }

        public IActionResult UsersByRep()
        {
            var users = _context.Users
                .OrderByDescending(u => u.Reputation)
                .Take(10)
                .Select(u => new UserModel 
                {  
                    DisplayName = u.DisplayName, 
                    Reputation = u.Reputation
                })
                .ToList();

            #region Better Code
            // Go to StackOverflowContext.cs
            #endregion

            return Ok(users);
        }
    }
}
