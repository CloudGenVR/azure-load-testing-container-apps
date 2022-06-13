using Microsoft.AspNetCore.Mvc;
using System.Security.Cryptography;

namespace Sample.ContainerApps.Controllers
{
    [Route("[controller]")]
    [ApiController]
    public class PingController : ControllerBase
    {
        private readonly HttpClient bu;
        public PingController(IHttpClientFactory factory)
        {
            bu = factory.CreateClient("BusinessLogic");
        }

        [HttpGet]
        public async Task<IActionResult> GetAsync()
        {
            DateTime startDate = DateTime.UtcNow;
            var random = RandomNumberGenerator.GetInt32(300, 10_000);
            var pongData = await bu.GetFromJsonAsync<Pong>($"pong/{random}");
            pongData.DurationInMilliSeconds = (pongData.ExecutedAt - startDate).TotalMilliseconds;
            var returnDate = DateTime.UtcNow;
            return Ok(new PingPoing
            {
                RandomizeDelay = random,
                Ping = new Pong
                {
                    ExecutedAt = DateTime.UtcNow,
                    Label = "FromIngress",
                    DurationInMilliSeconds = (returnDate - startDate).TotalMilliseconds
                },
                Pong = pongData!
            });
        }
    }

    public class Pong
    {
        public string Label { get; set; }
        public DateTime ExecutedAt { get; set; }
        public double DurationInMilliSeconds { get; set; }
    }

    public class PingPoing
    {
        public int RandomizeDelay { get; set; }
        public Pong Pong { get; set; }
        public Pong Ping { get; set; }
    }
}
