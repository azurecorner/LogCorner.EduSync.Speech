using LogCorner.EduSync.Speech.Application.UseCases;
using LogCorner.EduSync.Speech.Infrastructure;
using LogCorner.EduSync.Speech.Presentation.Exceptions;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.OpenApi.Models;
using System.Collections.Generic;

namespace LogCorner.EduSync.Speech.Presentation
{
    public class Startup
    {
        private IConfiguration Configuration { get; }

        public Startup(IConfiguration configuration)
        {
            Configuration = configuration;
        }

        public void ConfigureServices(IServiceCollection services)
        {
            
            services.AddScoped<ISpeechUseCase, SpeechUseCase>();
  
            services.RegisterCosmosDependencies(Configuration);
            services.AddCors(options =>
            {
                options.AddPolicy(
                    "CorsPolicy",
                    builder => builder.WithOrigins(Configuration["allowedOrigins"].Split(","))
                        .AllowAnyMethod()
                        .AllowAnyHeader()
                        .AllowCredentials()
                         );
            });

            services.AddSwaggerGen(options =>
            {
                options.SwaggerDoc("v1", new OpenApiInfo
                {
                    Title = "LogCorner Micro Service Event Driven Architecture - Query HTTP API",
                    Version = "v1",
                    Description = "The Speech Micro Service Query HTTP API"
                });
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

            app.UseCors("CorsPolicy");

            app.UseMiddleware<ExceptionMiddleware>();
            app.UseRouting();
            string pathBase = Configuration["pathBase"];
            app.UseSwagger(
                x =>
                {
                    if (!string.IsNullOrWhiteSpace(pathBase))
                    {
                        x.RouteTemplate = "swagger/{documentName}/swagger.json";
                        x.PreSerializeFilters.Add((swaggerDoc, httpReq) =>
                        {
                            swaggerDoc.Servers = new List<OpenApiServer> { new OpenApiServer { Url = $"https://{httpReq.Host.Value}{pathBase}" } };
                        });
                    }
                })
                .UseSwaggerUI(c =>
                {
                    c.SwaggerEndpoint("../swagger/v1/swagger.json", "WebApi v1");
                });

            app.UseAuthentication();
            app.UseAuthorization();

            app.UseEndpoints(endpoints =>
            {
                endpoints.MapControllers();
            });

            if (!string.IsNullOrWhiteSpace(pathBase))
            {
                app.UsePathBase(new Microsoft.AspNetCore.Http.PathString(pathBase));
            }
        }
    }
}