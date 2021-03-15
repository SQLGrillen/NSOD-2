using CommonOrmProblems.Web.Data;
using CommonOrmProblems.Web.Entities;
using CommonOrmProblems.Web.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using System;
using System.Linq;

namespace CommonOrmProblems.Web.Controllers
{
    public class CommentController : Controller
    {
        private readonly ILogger<CommentController> _logger; 
        private readonly StackOverflowContext _context;

        public CommentController(
            ILogger<CommentController> logger,
            StackOverflowContext context)
        {
            _logger = logger;
            _context = context;
        }

        [HttpGet]
        public IActionResult TopOneHundredV1()
        {
            var comments = _context.Comments
                .Take(100) // TOP (100)
                .ToList();

            var models = comments.Select(c => new CommentModel
            {
                DisplayName = c.User.DisplayName,
                Text = c.Text
            });

            return Ok(models);
        }

        [HttpGet]
        public IActionResult TopOneHundredV2()
        {

            var comments = _context.Comments
                .Include(c => c.User) // JOIN to the users table
                .Take(100) // TOP (100)
                .ToList();

            var models = comments.Select(c => new CommentModel
            {
                DisplayName = c.User.DisplayName,
                Text = c.Text
            });

            return Ok(models);
        }

        [HttpGet]
        public IActionResult TopOneHundredV3()
        {

            var models = _context.Comments
                .Include(c => c.User) // JOIN to the users table
                .Take(100) // TOP (100)
                .Select(c => new CommentModel // Define the SELECT list
                {
                    DisplayName = c.User.DisplayName,
                    Text = c.Text
                })
                .ToList();

            return Ok(models);
        }

        [HttpGet]
        public IActionResult KitchenSinkSearch(
            DateTime? from, 
            DateTime? to, 
            int? minScore, 
            string userDisplayName)
        {
            var models = _context.Comments
                .Where(c =>
                    (c.CreationDate > from || from == null)
                    && (c.CreationDate < to || to == null)
                    && (c.Score > minScore || minScore == null)
                    && (c.User.DisplayName == userDisplayName || userDisplayName == null))
                .Select(c => new CommentModel
                {
                    DisplayName = c.User.DisplayName,
                    Text = c.Text
                })
                .ToList();

            #region For Legacy EF
            //var query = _context.Comments.AsQueryable();

            //if (from.HasValue) query = query.Where(c => c.CreationDate > from.Value);
            //if (to.HasValue) query = query.Where(c => c.CreationDate < to.Value);
            //if (minScore.HasValue) query = query.Where(c => c.Score > minScore.Value);
            //if (!string.IsNullOrWhiteSpace(userDisplayName))
            //{
            //    query = query.Where(c => c.User.DisplayName == userDisplayName);
            //}

            //var models = query
            //    .Select(c => new CommentModel
            //    {
            //        DisplayName = c.User.DisplayName,
            //        Text = c.Text
            //    })
            //    .ToList();
            #endregion

            return Ok(models);
        }
    }
}
