//
//  FoundationViewModel.swift
//  CardGameApp
//
//  Created by TaeHyeonLee on 2018. 1. 30..
//  Copyright © 2018년 ChocOZerO. All rights reserved.
//

import Foundation

class FoundationsViewModel: CardStacksProtocol {
    private var cardStacks: [CardStack] = [CardStack]() {
        didSet {
            var cardImagesPack: [CardImages] = []
            cardStacks.forEach { cardImagesPack.append($0.getImagesAll()) }
            NotificationCenter.default.post(name: .foundation,
                                            object: self,
                                            userInfo: [Keyword.foundationImages.value: cardImagesPack])
        }
    }

    init() {
        setNewFoundations()
    }

    func push(card: Card) -> Bool {
        guard let targetPosition = availablePosition(of: card) else { return false }
        cardStacks[targetPosition.xIndex].push(card: card)
        return true
    }

    func pop(index: Int) -> Card? {
        return cardStacks[index].pop()
    }

    func getSelectedCardInformation(image: String) -> CardInformation? {
        guard let selectedCard = getSelectedCard(image: image) else { return nil }
        guard let selectedCardIndexes = getSelectedCardPosition(of: selectedCard) else { return nil }
        return (card: selectedCard, indexes: selectedCardIndexes)
    }

    private func getSelectedCard(image: String) -> Card? {
        var selectedCard: Card? = nil
        cardStacks.forEach {
            if let card = $0.selectedCard(image: image) {
                selectedCard = card
            }
        }
        return selectedCard
    }

    private func getSelectedCardPosition(of card: Card) -> CardIndexes? {
        for xIndex in cardStacks.indices {
            if let yIndex = cardStacks[xIndex].index(of: card) {
                return (xIndex: xIndex, yIndex: yIndex)
            }
        }
        return nil
    }

    func availablePosition(of card: Card) -> CardIndexes? {
        for xIndex in cardStacks.indices {
            if cardStacks[xIndex].isStackable(card: card) {
                return (xIndex: xIndex, yIndex: cardStacks[xIndex].count)
            }
        }
        return nil
    }

    func reset() {
        cardStacks = []
        setNewFoundations()
    }

    private func setNewFoundations() {
        for _ in 0..<Figure.Count.foundations.value {
            cardStacks.append(CardStack(cardPack: []))
        }
    }
}
