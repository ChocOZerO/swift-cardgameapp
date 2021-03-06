//
//  ViewController.swift
//  CardGameApp
//
//  Created by TaeHyeonLee on 2018. 1. 26..
//  Copyright © 2018년 ChocOZerO. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    // Foundations
    private var foundationsView: FoundationsView!
    private var foundationsVM: FoundationsViewModel!
    // OpenedCardDeck
    private var openedCardDeckView: OpenedCardDeckView!
    private var openedCardDeckVM: OpenedCardDeckViewModel!
    // dealer
    private var cardDeckView: CardDeckView!
    private var dealerAction: DealerAction!
    // SevenPiles
    private var sevenPilesView: SevenPilesView!
    private var sevenPilesVM: SevenPilesViewModel!
    // card information
    private var cardWidth: CGFloat!
    private var cardMargin: CGFloat!
    private var cardRatio: CGFloat!
    // move controller for gusture reactions
    private var moveController: MoveController?

    override func viewDidLoad() {
        super.viewDidLoad()
        setNotifications()
        setCardGame()
        configureCardGame()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    private func setNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(pushToFoundations(notification:)),
            name: .foundation,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(changeOpenedCardDeck(notification:)),
            name: .openedCardDeck,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(changeSevenPiles(notification:)),
            name: .sevenPiles,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(tappedCardDeck(notification:)),
            name: .tappedCardDeck,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(doubleTapped(notification:)),
            name: .doubleTapped,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(dragging(notification:)),
            name: .drag,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(showSuccess),
            name: .success,
            object: nil)
    }

    // set Cards
    private func setCardGame() {
        setCardSize()
        setCardDeck()
    }
    private func setCardSize() {
        cardWidth = UIScreen.main.bounds.width / CGFloat(Figure.Size.countInRow.value)
        cardMargin = cardWidth / CGFloat(Figure.Size.yGap.value)
        cardRatio = CGFloat(Figure.Size.ratio.value)
    }
    private func setCardDeck() {
        dealerAction = DealerAction()
        dealerAction.shuffle()
    }

    // draw card game
    private func configureCardGame() {
        configureBackground()
        configureFoundations()
        configureOpenedCardDeck()
        configureCardDeck()
        spreadSevenPiles()
    }
    private func configureBackground() {
        view.backgroundColor = UIColor(patternImage: UIImage(named: Figure.Image.background.value)!)
    }
    private func getCardLocation(index: Int, topMargin: CGFloat) -> CGRect {
        let cardWidth = UIScreen.main.bounds.width
                        / CGFloat(Figure.Count.cardPiles.value)
                        - CGFloat(Figure.Size.xGap.value)
        let cardHeight = cardWidth * CGFloat(Figure.Size.ratio.value)
        return CGRect(x: (cardWidth + CGFloat(Figure.Size.xGap.value)) * CGFloat(index), y: topMargin,
                      width: cardWidth, height: cardHeight)
    }
    private func configureFoundations() {
        let foundationsViewWidth = UIScreen.main.bounds.width
                                    / CGFloat(Figure.Count.cardPiles.value)
                                    * CGFloat(Figure.Count.foundations.value)
        let foundationsViewHeight = UIScreen.main.bounds.width
                                    / CGFloat(Figure.Count.cardPiles.value)
                                    * CGFloat(Figure.Size.ratio.value)
        let foundationsViewFrame = CGRect(x: UIScreen.main.bounds.origin.x,
                                          y: CGFloat(Figure.YPosition.topMargin.value),
                                          width: foundationsViewWidth,
                                          height: foundationsViewHeight)
        foundationsView = FoundationsView(frame: foundationsViewFrame)
        foundationsVM = FoundationsViewModel.sharedInstance()
        view.addSubview(foundationsView)
    }
    private func configureCardDeck() {
        let cardDeckFrame = getCardLocation(index: Figure.XPosition.cardDeck.value,
                                            topMargin: CGFloat(Figure.YPosition.topMargin.value))
        cardDeckView = CardDeckView(frame: cardDeckFrame)
        view.addSubview(cardDeckView)
    }
    private func configureOpenedCardDeck() {
        let openedCardDeckFrame = getCardLocation(index: Figure.XPosition.openedCardDeck.value,
                                                  topMargin: CGFloat(Figure.YPosition.topMargin.value))
        openedCardDeckView = OpenedCardDeckView(frame: openedCardDeckFrame)
        openedCardDeckVM = OpenedCardDeckViewModel.sharedInstance()
        view.addSubview(openedCardDeckView)
    }
    private func spreadSevenPiles() {
        let sevenPilesViewFrame = CGRect(x: UIScreen.main.bounds.origin.x,
                                         y: CGFloat(Figure.YPosition.cardPileTopMargin.value),
                                         width: UIScreen.main.bounds.width,
                                         height: UIScreen.main.bounds.height)
        sevenPilesView = SevenPilesView(frame: sevenPilesViewFrame)
        sevenPilesVM = SevenPilesViewModel.sharedInstance()
        sevenPilesVM.spreadCardPiles(sevenPiles: dealerAction.getCardPacks(packCount: Figure.Count.cardPiles.value))
        view.addSubview(sevenPilesView)
    }

    @objc private func showSuccess() {
        let alert = UIAlertController(title: "Game Success", message: "Congratulations!!!", preferredStyle: .alert)
        let okAction = UIAlertAction(
            title: "OK",
            style: .default,
            handler: { _ in
                alert.dismiss(animated: true, completion: nil)
            }
        )
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

// MARK: View ReDraw
extension ViewController {
    @objc private func pushToFoundations(notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: [CardImages]] else { return }
        guard let foundationImages = userInfo[Keyword.foundationImages.value] else { return }
        foundationsView.imagesPack = foundationImages
    }

    @objc private func changeOpenedCardDeck(notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: CardImages] else { return }
        guard let openedCardDeckImages = userInfo[Keyword.openedCardImages.value] else { return }
        openedCardDeckView.cardImages = openedCardDeckImages
    }

    @objc private func changeSevenPiles(notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: [CardImages]] else { return }
        guard let sevenPilesImages = userInfo[Keyword.sevenPilesImages.value] else { return }
        sevenPilesView.imagesPack = sevenPilesImages
    }
}

// MARK: Tab On CardDeck Gesture
extension ViewController {
    @objc func tappedCardDeck(notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: Any] else { return }
        if (userInfo[Keyword.tappedCardDeck.value] as? CardDeckView) != nil {
            view.isUserInteractionEnabled = false
            selectOpenedCardDeckViewImage()
            selectCardDeckViewImage()
            view.isUserInteractionEnabled = true
        }
    }
    private func selectOpenedCardDeckViewImage() {
        guard let card = dealerAction.open() else {
            dealerAction.reLoad(cardPack: openedCardDeckVM.reLoad())
            return
        }
        _ = openedCardDeckVM.push(card: card)
    }
    private func selectCardDeckViewImage() {
        cardDeckView.image = dealerAction.isRemain() ? cardDeckView.backImage : cardDeckView.refreshImage
    }
}

// MARK: Shake event
extension ViewController {
    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        super.motionBegan(motion, with: event)
        if motion == .motionShake {
            foundationsVM.reset()
            foundationsView.reset()
            openedCardDeckVM.reset()
            openedCardDeckView.reset()
            dealerAction.reset()
            dealerAction.shuffle()
            cardDeckView.image = cardDeckView.backImage
            sevenPilesVM.reset()
            sevenPilesView.reset()
            spreadSevenPiles()
        }
    }
}

// MARK: Double Tap Gesture
extension ViewController {
    @objc private func doubleTapped(notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: Any] else { return }
        guard let recognizer = userInfo[Keyword.doubleTapped.value] as? UITapGestureRecognizer else { return }
        guard let cardView = recognizer.view as? CardView else { return }
        guard let original = OriginalInformation(cardView: cardView) else { return }
        moveController = MoveController(original: original)
        moveController?.doubleTap()
    }
}

// MARK: Drag & Drop
extension ViewController {
    @objc func dragging(notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: Any] else { return }
        guard let recognizer = userInfo[Keyword.drag.value] as? UIPanGestureRecognizer else { return }
        guard let cardView = recognizer.view as? CardView else { return }
        switch recognizer.state {
        case .began:
            guard let original = OriginalInformation(cardView: cardView) else { return }
            moveController = MoveController(original: original)
            moveController?.dragBegan()
        case .changed:
            moveController?.dragChanged(with: recognizer)
        case .ended:
            moveController?.dragEnded(at: recognizer.location(in: view))
        default:
            break
        }
    }
}
