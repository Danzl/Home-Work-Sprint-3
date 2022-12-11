import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var statisticService: StatisticService!
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    private var alertPresenter: AlertPresenter?
    private var vSpinner : [UIView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        statisticService = StatisticServiceImplementation()
        alertPresenter = AlertPresenter(viewController: self)
        activityIndicator.startAnimating()
        
        
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else { return }
        blockButtons()
        showAnswerResult(isCorrect: true == currentQuestion.correctAnswer)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else { return }
        blockButtons()
        showAnswerResult(isCorrect: false == currentQuestion.correctAnswer)
    }
    
    private func showLoadingIndicator() {
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 40, 40))
        self.view.addSubview(activityIndicator)
    }
    
    private func showNetworkError(message: String) {
        activityIndicator.stopAnimating()
        let netError = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] _ in
            guard let self = self else { return }
            self.restartGame()
            self.questionFactory?.loadData()
        }
        
        alertPresenter = AlertPresenter(viewController: self)
        alertPresenter?.showAlert(quiz: netError)
    }
    
    func didRecieveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }

    private func getAppColor(_ name: String) -> CGColor {
        if let color = UIColor(named: name) {
            return color.cgColor
        } else {
            return UIColor.white.cgColor
        }
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        imageView.layer.borderWidth = 8
        imageView.layer.masksToBounds = true
        imageView.layer.borderColor = isCorrect ? getAppColor("ypGreen") : getAppColor("ypRed")
        if isCorrect {
            correctAnswers += 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResults()
        }
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.layer.borderWidth = 0
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        let alertModel = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText)
            { [weak self] _ in
                guard let self = self else { return }
                self.restartGame()
                self.activityIndicator.stopAnimating()
        }
        alertPresenter?.showAlert(quiz: alertModel)
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            statisticService?.store(correct: correctAnswers, total: questionsAmount)
            guard let bestGame = statisticService?.bestGame else {return}
                          
            let text = "Ваш результат: \(correctAnswers) из 10\n" +
            "Количество сыгранных квизов: \(statisticService.gamesCount)\n" +
            "Ваш рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(bestGame.date.dateTimeString))\n" +
            "Средняя точность: \(Int(statisticService.totalAccuracy))%\n"
                
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
                
                self.correctAnswers = 0
                show(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }
    
    func didLoadDateFromServer() {
        activityIndicator.stopAnimating()
        questionFactory?.requestNextQuestion()
     }
    
    func didFailToLoadData(with error: Error) {
         showNetworkError(message: error.localizedDescription)
     }
    
    private func restartGame() {
        self.activityIndicator.startAnimating()
        self.currentQuestionIndex = 0
        self.questionFactory?.requestNextQuestion()
        self.correctAnswers = 0
    }
    
    private func blockButtons() {
        yesButton.isEnabled = false
        noButton.isEnabled = false
        activityIndicator.startAnimating()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else {return}
            self.yesButton.isEnabled = true
            self.noButton.isEnabled = true
            self.activityIndicator.stopAnimating()
        }
    }
}
