import Foundation
import SwiftUI

final class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @Published var currentLanguage: Language = .english
    @AppStorage("selectedLanguage") private var storedLanguage: String = "en"
    
    var hasUserSetLanguage: Bool {
        UserDefaults.standard.string(forKey: "selectedLanguage") != nil
    }
    
    enum Language: String, CaseIterable, Identifiable {
        case english = "en"
        case spanish = "es"
        case french = "fr"
        case german = "de"
        case chinese = "zh"
        case japanese = "ja"
        
        var id: String { rawValue }
        
        var displayName: String {
            switch self {
            case .english: return "English"
            case .spanish: return "Español"
            case .french: return "Français"
            case .german: return "Deutsch"
            case .chinese: return "中文"
            case .japanese: return "日本語"
            }
        }
        
        var nativeName: String {
            switch self {
            case .english: return "English"
            case .spanish: return "Español"
            case .french: return "Français"
            case .german: return "Deutsch"
            case .chinese: return "中文"
            case .japanese: return "日本語"
            }
        }
    }
    
    private init() {
        if let savedLanguageCode = UserDefaults.standard.string(forKey: "selectedLanguage"),
           let language = Language(rawValue: savedLanguageCode) {
            currentLanguage = language
            storedLanguage = savedLanguageCode
        } else {
            currentLanguage = .english
            storedLanguage = Language.english.rawValue
        }
        
        UserDefaults.standard.set([currentLanguage.rawValue], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }
    
    func setLanguage(_ language: Language) {
        DispatchQueue.main.async { [weak self] in
            self?.currentLanguage = language
            self?.storedLanguage = language.rawValue
        }
        
        UserDefaults.standard.set([language.rawValue], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }
    
    func localizedString(_ key: String) -> String {
        return localizedStrings[currentLanguage]?[key] ?? localizedStrings[.english]?[key] ?? key
    }
    
    private let localizedStrings: [Language: [String: String]] = [
        .english: [
            "recordings": "Recordings",
            "record_call": "Record Call",
            "transcripts": "Transcripts",
            "settings": "Settings",
            
            "no_recordings": "No Recordings Yet",
            "your_recordings_appear": "Your recorded calls will appear here",
            "tap_record": "Tap the Record Call tab to get started",
            "all": "All",
            "today": "Today",
            "week": "Week",
            "search_recordings": "Search recordings...",
            
            "call_recording": "Call Recording",
            "date": "Date",
            "time": "Time",
            "duration": "Duration",
            "transcript": "Transcript",
            "cloud_sync": "Cloud Sync",
            "available": "Available",
            "uploaded": "Uploaded",
            "play_recording": "Play Recording",
            "pause": "Pause",
            "play": "Play",
            "share": "Share",
            "delete": "Delete",
            "back": "Back",
            "recording_id": "Recording ID",
            
            "no_transcripts": "No Transcripts Yet",
            "transcript_available_premium": "Transcript available with Premium",
            "transcript_not_available": "Transcript not available",
            "synced": "Synced",
            "copy": "Copy",
            "copied": "Copied!",
            
            "profile": "Profile",
            "language": "Language",
            "privacy_security": "Privacy & Security",
            "subscription": "Subscription",
            "legal": "Legal",
            "account": "Account",
            "notifications": "Notifications",
            "push_notifications": "Push Notifications",
            "email_notifications": "Email Notifications",
            "data_encryption": "Data Encryption",
            "end_to_end_encrypted": "End-to-end encrypted",
            "privacy_policy": "Privacy Policy",
            "terms_service": "Terms of Service",
            "current_plan": "Current Plan",
            "free_plan": "Free Plan",
            "premium_plan": "Premium Plan",
            "upgrade_premium": "Upgrade to Premium",
            "delete_data": "Delete Data",
            "done": "Done",
            
            "welcome_back": "Welcome Back",
            "sign_in_account": "Sign in to your account",
            "create_account": "Create Account",
            "sign_up_started": "Sign up to get started",
            "continue_guest": "Continue as Guest"
        ],
        .spanish: [
            "recordings": "Grabaciones",
            "record_call": "Grabar Llamada",
            "transcripts": "Transcripciones",
            "settings": "Configuración",
            
            "no_recordings": "Aún No Hay Grabaciones",
            "your_recordings_appear": "Sus llamadas grabadas aparecerán aquí",
            "tap_record": "Toque la pestaña Grabar Llamada para comenzar",
            "all": "Todas",
            "today": "Hoy",
            "week": "Semana",
            "search_recordings": "Buscar grabaciones...",
            
            "call_recording": "Grabación de Llamada",
            "date": "Fecha",
            "time": "Hora",
            "duration": "Duración",
            "transcript": "Transcripción",
            "cloud_sync": "Sincronización en la Nube",
            "available": "Disponible",
            "uploaded": "Subido",
            "play_recording": "Reproducir Grabación",
            "pause": "Pausar",
            "play": "Reproducir",
            "share": "Compartir",
            "delete": "Eliminar",
            "back": "Atrás",
            "recording_id": "ID de Grabación",
            
            // Transcripts
            "no_transcripts": "Aún No Hay Transcripciones",
            "transcript_available_premium": "Transcripción disponible con Premium",
            "transcript_not_available": "Transcripción no disponible",
            "synced": "Sincronizado",
            "copy": "Copiar",
            "copied": "¡Copiado!",
            
            // Settings
            "profile": "Perfil",
            "language": "Idioma",
            "privacy_security": "Privacidad y Seguridad",
            "subscription": "Suscripción",
            "legal": "Legal",
            "account": "Cuenta",
            "notifications": "Notificaciones",
            "push_notifications": "Notificaciones Push",
            "email_notifications": "Notificaciones por Email",
            "data_encryption": "Cifrado de Datos",
            "end_to_end_encrypted": "Cifrado de extremo a extremo",
            "privacy_policy": "Política de Privacidad",
            "terms_service": "Términos de Servicio",
            "current_plan": "Plan Actual",
            "free_plan": "Plan Gratuito",
            "premium_plan": "Plan Premium",
            "upgrade_premium": "Actualizar a Premium",
            "delete_data": "Eliminar Datos",
            "done": "Hecho",
            
            // Auth
            "welcome_back": "Bienvenido de Nuevo",
            "sign_in_account": "Inicia sesión en tu cuenta",
            "create_account": "Crear Cuenta",
            "sign_up_started": "Regístrate para comenzar",
            "continue_guest": "Continuar como Invitado"
        ],
        .french: [
            "recordings": "Enregistrements",
            "record_call": "Enregistrer Appel",
            "transcripts": "Transcriptions",
            "settings": "Paramètres",
            "no_recordings": "Aucun Enregistrement",
            "your_recordings_appear": "Vos appels enregistrés apparaîtront ici",
            "tap_record": "Appuyez sur l'onglet Enregistrer pour commencer",
            "welcome_back": "Bon Retour",
            "sign_in_account": "Connectez-vous à votre compte",
            "create_account": "Créer un Compte",
            "sign_up_started": "Inscrivez-vous pour commencer",
            "continue_guest": "Continuer en Invité"
        ],
        .german: [
            "recordings": "Aufnahmen",
            "record_call": "Anruf Aufnehmen",
            "transcripts": "Transkripte",
            "settings": "Einstellungen",
            "no_recordings": "Noch Keine Aufnahmen",
            "your_recordings_appear": "Ihre aufgenommenen Anrufe erscheinen hier",
            "tap_record": "Tippen Sie auf Anruf Aufnehmen um zu beginnen",
            "welcome_back": "Willkommen Zurück",
            "sign_in_account": "Melden Sie sich in Ihrem Konto an",
            "create_account": "Konto Erstellen",
            "sign_up_started": "Registrieren Sie sich um zu beginnen",
            "continue_guest": "Als Gast Fortfahren"
        ],
        .chinese: [
            "recordings": "录音",
            "record_call": "录制通话",
            "transcripts": "转录",
            "settings": "设置",
            "no_recordings": "暂无录音",
            "your_recordings_appear": "您录制的通话将显示在这里",
            "tap_record": "点击录制通话标签开始",
            "welcome_back": "欢迎回来",
            "sign_in_account": "登录您的账户",
            "create_account": "创建账户",
            "sign_up_started": "注册开始使用",
            "continue_guest": "以访客身份继续"
        ],
        .japanese: [
            "recordings": "録音",
            "record_call": "通話録音",
            "transcripts": "転写",
            "settings": "設定",
            "no_recordings": "録音はまだありません",
            "your_recordings_appear": "録音された通話がここに表示されます",
            "tap_record": "通話録音タブをタップして開始",
            "welcome_back": "お帰りなさい",
            "sign_in_account": "アカウントにサインイン",
            "create_account": "アカウント作成",
            "sign_up_started": "サインアップして開始",
            "continue_guest": "ゲストとして続行"
        ]
    ]
}

extension View {
    func localized(_ key: String) -> String {
        LocalizationManager.shared.localizedString(key)
    }
}
