import Foundation

struct QuizData: Codable {
    var success: Bool
    var quiz: [Quiz]
    
    init(success: Bool = true, quiz: [Quiz] = []) {
        self.success = success
        self.quiz = quiz
    }
}

struct Quiz: Codable {
    var id: Int
    var quiz_type: String
    var question: String?
    var right_answer: String?
    var wrong_answer: String?
    var use_question_audio: Int
    var question_audio_url: String?
    var question_img_url: String?
    var right_answer_img_url: String?
    var wrong_answer_img_url: String?

    var isUseQuestionAudio: Bool {
        return use_question_audio == 1
    }
}
