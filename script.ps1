# Ejecuta esto desde la raíz del proyecto Flutter (app_tecnicos)

$carpetas = @(
    "lib/core/api",
    "lib/core/storage",
    "lib/core/theme",
    "lib/core/router",
    "lib/features/auth/data",
    "lib/features/auth/presentation/providers",
    "lib/features/tickets/data/models",
    "lib/features/tickets/presentation/providers",
    "lib/features/checador/data",
    "lib/features/checador/presentation/providers",
    "lib/features/refacciones/data/models",
    "lib/features/refacciones/presentation/providers"
)

foreach ($c in $carpetas) {
    New-Item -ItemType Directory -Force -Path $c | Out-Null
}

$archivos = @(
    "lib/core/api/api_client.dart",
    "lib/core/api/api_exception.dart",
    "lib/core/storage/token_storage.dart",
    "lib/core/storage/local_db.dart",
    "lib/core/theme/app_theme.dart",
    "lib/core/router/app_router.dart",

    "lib/features/auth/data/auth_repository.dart",
    "lib/features/auth/presentation/login_screen.dart",
    "lib/features/auth/presentation/providers/auth_provider.dart",

    "lib/features/tickets/data/tickets_repository.dart",
    "lib/features/tickets/data/models/ticket_model.dart",
    "lib/features/tickets/presentation/tickets_list_screen.dart",
    "lib/features/tickets/presentation/ticket_detail_screen.dart",
    "lib/features/tickets/presentation/providers/tickets_provider.dart",

    "lib/features/checador/data/checador_repository.dart",
    "lib/features/checador/presentation/checador_screen.dart",
    "lib/features/checador/presentation/providers/checador_provider.dart",

    "lib/features/refacciones/data/refacciones_repository.dart",
    "lib/features/refacciones/data/models/refaccion_model.dart",
    "lib/features/refacciones/presentation/refacciones_screen.dart",
    "lib/features/refacciones/presentation/providers/refacciones_provider.dart"
)

foreach ($a in $archivos) {
    New-Item -ItemType File -Force -Path $a | Out-Null
}

Write-Host "Estructura creada correctamente." -ForegroundColor Green