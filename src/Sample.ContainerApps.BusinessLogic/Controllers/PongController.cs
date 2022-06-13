using Microsoft.AspNetCore.Mvc;

namespace Sample.ContainerApps.BusinessLogic.Controllers
{
    [Route("[controller]")]
    [ApiController]
    public class PongController : ControllerBase
    {
        [HttpGet("{randomDelay}")]
        public async Task<IActionResult> GetAsync([FromRoute] int randomDelay)
        {
            await Task.Delay(randomDelay);
            return Ok(new Pong
            {
                ExecutedAt = DateTime.UtcNow,
                Label = "FromBusinnessLogic"
            });
        }
    }

    public class Pong
    {
        public string Label { get; set; }
        public DateTime ExecutedAt { get; set; }
    }
}
