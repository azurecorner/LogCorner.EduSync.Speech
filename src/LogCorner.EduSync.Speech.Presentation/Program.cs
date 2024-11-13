using LogCorner.EduSync.Speech.Application.EventSourcing;
using LogCorner.EduSync.Speech.Application.Interfaces;
using LogCorner.EduSync.Speech.Application.UseCases;
using LogCorner.EduSync.Speech.Command.SharedKernel;
using LogCorner.EduSync.Speech.Command.SharedKernel.Events;
using LogCorner.EduSync.Speech.Command.SharedKernel.Serialyser;
using LogCorner.EduSync.Speech.Domain.IRepository;
using LogCorner.EduSync.Speech.Domain.SpeechAggregate;
using LogCorner.EduSync.Speech.Infrastructure;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// Add builder.Services to the container.

ConfigureServiceCollection(builder);

var app = builder.Build();

ConfigureApplicationBuilder(app);

app.Run();

static void ConfigureServiceCollection(WebApplicationBuilder builder)
{
    builder.Services.AddControllers();
    // Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
    builder.Services.AddEndpointsApiExplorer();
    builder.Services.AddSwaggerGen();

    builder.Services.AddScoped<ICreateSpeechUseCase, SpeechUseCase>();
    builder.Services.AddScoped<IUpdateSpeechUseCase, SpeechUseCase>();
    builder.Services.AddScoped<IDeleteSpeechUseCase, SpeechUseCase>();
    var configuration = builder.Configuration;

    var connectionString = configuration["ConnectionStrings:SpeechDB"];

    builder.Services.AddDbContext<DataBaseContext>(o => o.UseSqlServer(connectionString));

    builder.Services.AddScoped(typeof(IRepository<,>), typeof(Repository<,>));

    builder.Services.AddScoped<ISpeechRepository, SpeechRepository>();

    builder.Services.AddScoped<IUnitOfWork, UnitOfWork>();

    builder.Services.AddTransient<IEventSourcingSubscriber, EventSourcingSubscriber>();

    builder.Services.AddScoped<IEventStoreRepository, EventStoreRepository<AggregateRoot<Guid>>>();
    builder.Services.AddTransient<IEventSerializer, JsonEventSerializer>();
    builder.Services.AddTransient<IProducerService, ProducerService>();
    builder.Services.AddTransient<IEventSourcingHandler<Event>, EventSourcingHandler>();
    builder.Services.AddScoped(typeof(IInvoker<>), typeof(Invoker<>));
    builder.Services.AddTransient<IDomainEventRebuilder, DomainEventRebuilder>();
    builder.Services.AddTransient<IJsonProvider, JsonDotNetProvider>();

    //builder.Services.AddProducer("localhost:9092", Configuration);
    builder.Services.AddScoped<IEventPublisher, EventPublisher>();
    builder.Services.AddSharedKernel();

    //builder.Services.AddCors(options =>
    //{
    //    builder.Services.AddCors(options =>
    //    {
    //        options.AddPolicy(
    //            "CorsPolicy",
    //            builder =>
    //            {
    //                var allowedOrigins = configuration["allowedOrigins"]?.Split(",") ?? Array.Empty<string>();
    //                builder.WithOrigins(allowedOrigins)
    //                    .AllowAnyMethod()
    //                    .AllowAnyHeader()
    //                    .AllowCredentials();
    //            });
    //    });
    //});
}

static void ConfigureApplicationBuilder(WebApplication app)
{
    // Configure the HTTP request pipeline.
    if (app.Environment.IsDevelopment())
    {
        app.UseSwagger();
        app.UseSwaggerUI();
    }
    app.UseCors("CorsPolicy");
    app.UseHttpsRedirection();
    string? pathBase = app.Configuration["pathBase"];

    if (!string.IsNullOrWhiteSpace(pathBase))
    {
        app.UsePathBase(new PathString(pathBase));
    }

    app.UseAuthorization();

    app.MapControllers();
}