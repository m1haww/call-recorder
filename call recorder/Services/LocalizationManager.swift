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
            "cancel": "Cancel",
            "delete_recording": "Delete Recording",
            "delete_recording_message": "Are you sure you want to delete this recording? This action cannot be undone.",
            "back": "Back",
            "recording_id": "Recording ID",
            
            "no_transcripts": "No Transcripts Yet",
            "transcript_available_premium": "Transcript available with Premium",
            "transcript_not_available": "Transcript not available",
            "synced": "Synced",
            "transcripts_unlock_ai": "Unlock the power of AI transcription",
            "transcripts_will_appear_here": "Your transcripts will appear here",
            "transcripts_feature_ai_title": "AI-Powered Transcriptions",
            "transcripts_feature_ai_subtitle": "Convert calls to searchable text instantly",
            "transcripts_feature_search_title": "Smart Search",
            "transcripts_feature_search_subtitle": "Find any conversation in seconds",
            "transcripts_feature_export_title": "Export & Share",
            "transcripts_feature_export_subtitle": "Save transcripts as text files",
            "start_free_trial": "Start your 3-day free trial",
            "record_first_call": "Record your first call",
            "transcripts_auto_generated": "Transcripts will be generated automatically\nafter each recording",
            "premium_active": "Premium Active",
            "unlimited_transcripts": "Unlimited Transcripts",
            "generating_transcript": "Generating transcript",
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
            "delete_data_message": "This action will delete all your recorded calls and data. Are you sure you want to continue?",
            "delete_data_success": "All data deleted successfully",
            "done": "Done",
            "edit": "Edit",
            "user": "User",
            "no_phone_number": "No phone number",
            "ok": "OK",
            "notification_error": "Notification Error",
            "data_usage": "Data Usage",
            "help_support": "Help & Support",
            "unlock_premium_features": "Unlock Premium Features",
            "unlock_premium_subtitle": "Get unlimited recordings and transcripts",
            "unlimited_recordings": "Unlimited recordings",
            "full_transcripts": "Full transcripts",
            "cloud_backup": "Cloud backup",
            "priority_support": "Priority support",
            "try_3_days_free": "Try 3 Days Free",
            "subscription_then": "Then %@",
            "premium": "Premium",
            
            "welcome_back": "Welcome Back",
            "sign_in_account": "Sign in to your account",
            "create_account": "Create Account",
            "sign_up_started": "Sign up to get started",
            "continue_guest": "Continue as Guest",

            "incoming_call": "Incoming Call",
            "outgoing_call": "Outgoing Call",
            "loading_service_number": "Loading service number...",
            "unable_make_call": "Unable to make phone call on this device",
            "record_incoming_calls": "Record Incoming Calls",
            "incoming_steps_intro": "When you receive a call, follow these steps:",
            "incoming_step_1": "Answer the incoming call",
            "incoming_step_2": "Tap 'Add Call' on your phone",
            "incoming_step_3": "Call our recording service",
            "incoming_step_4": "Merge the calls - recording starts automatically",
            "record_outgoing_calls": "Record Outgoing Calls",
            "outgoing_steps_intro": "Follow these steps to record your call:",
            "outgoing_step_1": "Call our recording service first",
            "outgoing_step_2": "Tap 'Add Call' on your phone",
            "outgoing_step_3": "Call the person you want to record",
            "outgoing_step_4": "Merge the calls - recording starts automatically",
            "call_our_service": "Call Our Service",
            "recording_merge_warning": "Recording starts automatically when calls are merged"
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
            "cancel": "Cancelar",
            "delete_recording": "Eliminar Grabación",
            "delete_recording_message": "¿Está seguro de que desea eliminar esta grabación? Esta acción no se puede deshacer.",
            "back": "Atrás",
            "recording_id": "ID de Grabación",
            "no_transcripts": "Aún No Hay Transcripciones",
            "transcript_available_premium": "Transcripción disponible con Premium",
            "transcript_not_available": "Transcripción no disponible",
            "synced": "Sincronizado",
            "transcripts_unlock_ai": "Desbloquee el poder de la transcripción con IA",
            "transcripts_will_appear_here": "Sus transcripciones aparecerán aquí",
            "transcripts_feature_ai_title": "Transcripciones con IA",
            "transcripts_feature_ai_subtitle": "Convierta llamadas en texto buscable al instante",
            "transcripts_feature_search_title": "Búsqueda Inteligente",
            "transcripts_feature_search_subtitle": "Encuentre cualquier conversación en segundos",
            "transcripts_feature_export_title": "Exportar y Compartir",
            "transcripts_feature_export_subtitle": "Guarde transcripciones como archivos de texto",
            "start_free_trial": "Comience su prueba gratuita de 3 días",
            "record_first_call": "Grabe su primera llamada",
            "transcripts_auto_generated": "Las transcripciones se generarán automáticamente\ndespués de cada grabación",
            "premium_active": "Premium Activo",
            "unlimited_transcripts": "Transcripciones Ilimitadas",
            "generating_transcript": "Generando transcripción",
            "copy": "Copiar",
            "copied": "¡Copiado!",
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
            "delete_data_message": "Esta acción eliminará todas sus llamadas grabadas y datos. ¿Está seguro de que desea continuar?",
            "delete_data_success": "Todos los datos eliminados correctamente",
            "done": "Hecho",
            "edit": "Editar",
            "user": "Usuario",
            "no_phone_number": "Sin número de teléfono",
            "ok": "Aceptar",
            "notification_error": "Error de notificación",
            "data_usage": "Uso de datos",
            "help_support": "Ayuda y soporte",
            "unlock_premium_features": "Desbloquear funciones Premium",
            "unlock_premium_subtitle": "Obtenga grabaciones y transcripciones ilimitadas",
            "unlimited_recordings": "Grabaciones ilimitadas",
            "full_transcripts": "Transcripciones completas",
            "cloud_backup": "Copia de seguridad en la nube",
            "priority_support": "Soporte prioritario",
            "try_3_days_free": "Prueba 3 días gratis",
            "subscription_then": "Luego %@",
            "premium": "Premium",
            "welcome_back": "Bienvenido de Nuevo",
            "sign_in_account": "Inicia sesión en tu cuenta",
            "create_account": "Crear Cuenta",
            "sign_up_started": "Regístrate para comenzar",
            "continue_guest": "Continuar como Invitado",

            "incoming_call": "Llamada Entrante",
            "outgoing_call": "Llamada Saliente",
            "loading_service_number": "Cargando número de servicio...",
            "unable_make_call": "No se puede realizar la llamada en este dispositivo",
            "record_incoming_calls": "Grabar Llamadas Entrantes",
            "incoming_steps_intro": "Cuando reciba una llamada, siga estos pasos:",
            "incoming_step_1": "Conteste la llamada entrante",
            "incoming_step_2": "Toque 'Añadir llamada' en su teléfono",
            "incoming_step_3": "Llame a nuestro servicio de grabación",
            "incoming_step_4": "Combine las llamadas: la grabación comienza automáticamente",
            "record_outgoing_calls": "Grabar Llamadas Salientes",
            "outgoing_steps_intro": "Siga estos pasos para grabar su llamada:",
            "outgoing_step_1": "Llame primero a nuestro servicio de grabación",
            "outgoing_step_2": "Toque 'Añadir llamada' en su teléfono",
            "outgoing_step_3": "Llame a la persona que desea grabar",
            "outgoing_step_4": "Combine las llamadas: la grabación comienza automáticamente",
            "call_our_service": "Llamar a Nuestro Servicio",
            "recording_merge_warning": "La grabación comienza automáticamente al combinar las llamadas"
        ],
        .french: [
            "recordings": "Enregistrements",
            "record_call": "Enregistrer Appel",
            "transcripts": "Transcriptions",
            "settings": "Paramètres",
            "no_recordings": "Aucun Enregistrement",
            "your_recordings_appear": "Vos appels enregistrés apparaîtront ici",
            "tap_record": "Appuyez sur l'onglet Enregistrer pour commencer",
            "cancel": "Annuler",
            "delete_recording": "Supprimer l'enregistrement",
            "delete_recording_message": "Êtes-vous sûr de vouloir supprimer cet enregistrement ? Cette action est irréversible.",
            "welcome_back": "Bon Retour",
            "sign_in_account": "Connectez-vous à votre compte",
            "create_account": "Créer un Compte",
            "sign_up_started": "Inscrivez-vous pour commencer",
            "continue_guest": "Continuer en Invité",

            "incoming_call": "Appel entrant",
            "outgoing_call": "Appel sortant",
            "loading_service_number": "Chargement du numéro de service...",
            "unable_make_call": "Impossible de passer un appel sur cet appareil",
            "record_incoming_calls": "Enregistrer les appels entrants",
            "incoming_steps_intro": "Lorsque vous recevez un appel, suivez ces étapes :",
            "incoming_step_1": "Répondez à l'appel entrant",
            "incoming_step_2": "Appuyez sur « Ajouter un appel » sur votre téléphone",
            "incoming_step_3": "Appelez notre service d'enregistrement",
            "incoming_step_4": "Fusionnez les appels - l'enregistrement démarre automatiquement",
            "record_outgoing_calls": "Enregistrer les appels sortants",
            "outgoing_steps_intro": "Suivez ces étapes pour enregistrer votre appel :",
            "outgoing_step_1": "Appelez d'abord notre service d'enregistrement",
            "outgoing_step_2": "Appuyez sur « Ajouter un appel » sur votre téléphone",
            "outgoing_step_3": "Appelez la personne que vous souhaitez enregistrer",
            "outgoing_step_4": "Fusionnez les appels - l'enregistrement démarre automatiquement",
            "call_our_service": "Appeler notre service",
            "recording_merge_warning": "L'enregistrement démarre automatiquement lorsque les appels sont fusionnés"
        ],
        .german: [
            "recordings": "Aufnahmen",
            "record_call": "Anruf Aufnehmen",
            "transcripts": "Transkripte",
            "settings": "Einstellungen",
            "no_recordings": "Noch Keine Aufnahmen",
            "your_recordings_appear": "Ihre aufgenommenen Anrufe erscheinen hier",
            "tap_record": "Tippen Sie auf Anruf Aufnehmen um zu beginnen",
            "cancel": "Abbrechen",
            "delete_recording": "Aufnahme löschen",
            "delete_recording_message": "Möchten Sie diese Aufnahme wirklich löschen? Diese Aktion kann nicht rückgängig gemacht werden.",
            "welcome_back": "Willkommen Zurück",
            "sign_in_account": "Melden Sie sich in Ihrem Konto an",
            "create_account": "Konto Erstellen",
            "sign_up_started": "Registrieren Sie sich um zu beginnen",
            "continue_guest": "Als Gast Fortfahren",

            "incoming_call": "Eingehender Anruf",
            "outgoing_call": "Ausgehender Anruf",
            "loading_service_number": "Servicenummer wird geladen...",
            "unable_make_call": "Anruf auf diesem Gerät nicht möglich",
            "record_incoming_calls": "Eingehende Anrufe aufnehmen",
            "incoming_steps_intro": "Wenn Sie einen Anruf erhalten, folgen Sie diesen Schritten:",
            "incoming_step_1": "Nehmen Sie den eingehenden Anruf an",
            "incoming_step_2": "Tippen Sie auf „Anruf hinzufügen“ auf Ihrem Telefon",
            "incoming_step_3": "Rufen Sie unseren Aufnahmedienst an",
            "incoming_step_4": "Führen Sie die Anrufe zusammen – die Aufnahme startet automatisch",
            "record_outgoing_calls": "Ausgehende Anrufe aufnehmen",
            "outgoing_steps_intro": "Folgen Sie diesen Schritten, um Ihren Anruf aufzunehmen:",
            "outgoing_step_1": "Rufen Sie zuerst unseren Aufnahmedienst an",
            "outgoing_step_2": "Tippen Sie auf „Anruf hinzufügen“ auf Ihrem Telefon",
            "outgoing_step_3": "Rufen Sie die Person an, die Sie aufnehmen möchten",
            "outgoing_step_4": "Führen Sie die Anrufe zusammen – die Aufnahme startet automatisch",
            "call_our_service": "Servicedienst anrufen",
            "recording_merge_warning": "Die Aufnahme startet automatisch, wenn die Anrufe zusammengeführt werden"
        ],
        .chinese: [
            "recordings": "录音",
            "record_call": "录制通话",
            "transcripts": "转录",
            "settings": "设置",
            "no_recordings": "暂无录音",
            "your_recordings_appear": "您录制的通话将显示在这里",
            "tap_record": "点击录制通话标签开始",
            "cancel": "取消",
            "delete_recording": "删除录音",
            "delete_recording_message": "确定要删除此录音吗？此操作无法撤销。",
            "welcome_back": "欢迎回来",
            "sign_in_account": "登录您的账户",
            "create_account": "创建账户",
            "sign_up_started": "注册开始使用",
            "continue_guest": "以访客身份继续",

            "incoming_call": "来电",
            "outgoing_call": "去电",
            "loading_service_number": "正在加载服务号码...",
            "unable_make_call": "此设备无法拨打电话",
            "record_incoming_calls": "录制来电",
            "incoming_steps_intro": "接到电话时，请按以下步骤操作：",
            "incoming_step_1": "接听来电",
            "incoming_step_2": "在手机上点击「添加通话」",
            "incoming_step_3": "拨打我们的录音服务",
            "incoming_step_4": "合并通话 - 录音将自动开始",
            "record_outgoing_calls": "录制去电",
            "outgoing_steps_intro": "请按以下步骤录制您的通话：",
            "outgoing_step_1": "先拨打我们的录音服务",
            "outgoing_step_2": "在手机上点击「添加通话」",
            "outgoing_step_3": "拨打您要录制对象的电话",
            "outgoing_step_4": "合并通话 - 录音将自动开始",
            "call_our_service": "拨打我们的服务",
            "recording_merge_warning": "合并通话后录音将自动开始"
        ],
        .japanese: [
            "recordings": "録音",
            "record_call": "通話録音",
            "transcripts": "転写",
            "settings": "設定",
            "no_recordings": "録音はまだありません",
            "your_recordings_appear": "録音された通話がここに表示されます",
            "tap_record": "通話録音タブをタップして開始",
            "cancel": "キャンセル",
            "delete_recording": "録音を削除",
            "delete_recording_message": "この録音を削除してもよろしいですか？この操作は元に戻せません。",
            "welcome_back": "お帰りなさい",
            "sign_in_account": "アカウントにサインイン",
            "create_account": "アカウント作成",
            "sign_up_started": "サインアップして開始",
            "continue_guest": "ゲストとして続行",

            "incoming_call": "着信",
            "outgoing_call": "発信",
            "loading_service_number": "サービス番号を読み込み中...",
            "unable_make_call": "このデバイスでは電話をかけられません",
            "record_incoming_calls": "着信を録音",
            "incoming_steps_intro": "着信があったら、次の手順に従ってください：",
            "incoming_step_1": "着信に応答する",
            "incoming_step_2": "スマートフォンで「通話を追加」をタップ",
            "incoming_step_3": "録音サービスに電話する",
            "incoming_step_4": "通話を統合する - 録音が自動で開始されます",
            "record_outgoing_calls": "発信を録音",
            "outgoing_steps_intro": "通話を録音するには、次の手順に従ってください：",
            "outgoing_step_1": "まず録音サービスに電話する",
            "outgoing_step_2": "スマートフォンで「通話を追加」をタップ",
            "outgoing_step_3": "録音したい相手に電話する",
            "outgoing_step_4": "通話を統合する - 録音が自動で開始されます",
            "call_our_service": "サービスに電話",
            "recording_merge_warning": "通話を統合すると録音が自動で開始されます"
        ]
    ]
}

extension View {
    func localized(_ key: String) -> String {
        LocalizationManager.shared.localizedString(key)
    }
}
