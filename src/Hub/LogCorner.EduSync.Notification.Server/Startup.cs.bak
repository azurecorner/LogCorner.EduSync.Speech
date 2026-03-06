using LogCorner.EduSync.Notification.Server.Hubs;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

namespace LogCorner.EduSync.Notification.Server
{
    public class Startup
    {
        public Startup(IConfiguration configuration)
        {
            Configuration = configuration;
        }

        private IConfiguration Configuration { get; }

        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {
            services.AddCors(options =>
            {
                var allowedOrigins = Configuration["allowedOrigins"]?.Split(",");
                options.AddPolicy("corsPolicy",
                    builder =>
                        builder.AllowAnyHeader()
                            .AllowAnyMethod()
                            .WithOrigins(allowedOrigins)
                            .AllowCredentials()
                    );
            });

            services.AddAuthentication(Configuration);

            services.AddSignalR(log =>
            {
                log.EnableDetailedErrors = true;
            });
            services.AddControllers();
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }
            else
            {
                app.UseHsts();
                app.UseHttpsRedirection();
            }
            app.UseCors("corsPolicy");

            app.UseRouting();

            app.UseAuthorization();

            app.UseEndpoints(endpoints =>
            {
                endpoints.MapControllers();
                bool.TryParse(Configuration["isAuthenticationEnabled"], out var isAuthenticationEnabled);
                if (!isAuthenticationEnabled)
                {
                    endpoints.MapHub<LogCornerHub<object>>("/logcornerhub");
                }
                else
                {
                    endpoints.MapHub<LogCornerHub<object>>("/logcornerhub").RequireAuthorization();
                }
            });
            var pathBase = Configuration["pathBase"];
            if (!string.IsNullOrWhiteSpace(pathBase))
            {
                app.UsePathBase(new PathString(pathBase));
            }
        }
    }
}