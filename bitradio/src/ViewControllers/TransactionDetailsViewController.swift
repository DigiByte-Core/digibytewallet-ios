//
//  TransactionDetailsViewController.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2017-02-09.
//  Copyright © 2017 breadwallet LLC. All rights reserved.
//

import UIKit

class TransactionDetailsViewController: UICollectionViewController, Subscriber, UICollectionViewDelegateFlowLayout {

    private let header = ModalHeaderView(title: S.TransactionDetails.title, style: .dark)
    private let onDismiss: ((UIViewController) -> Void)

    //MARK: - Public
    init(store: Store, transactions: [Transaction], selectedIndex: Int, kvStore: BRReplicatedKVStore, onDismiss: @escaping (UIViewController) -> Void) {
        self.store = store
        self.transactions = transactions
        self.selectedIndex = selectedIndex
        self.kvStore = kvStore
        self.isBtcSwapped = store.state.isBtcSwapped
        self.onDismiss = onDismiss
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.safeWidth-C.padding[4], height: UIScreen.main.bounds.height - C.padding[1])
        layout.sectionInset = UIEdgeInsetsMake(C.padding[1], 0, 0, 0)
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = C.padding[1]
        super.init(collectionViewLayout: layout)
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        var width = UIScreen.main.bounds.width
//        width = width > 375 ? 375 : width
//        return CGSize(width: width, height: UIScreen.main.bounds.height)
//    }

    //MARK: - Private
    fileprivate let store: Store
    fileprivate var transactions: [Transaction]
    fileprivate let selectedIndex: Int
    fileprivate let kvStore: BRReplicatedKVStore
    fileprivate let cellIdentifier = "CellIdentifier"
    fileprivate var isBtcSwapped: Bool
    fileprivate var rate: Rate?

    //The secretScrollView is to help with the limitation where if isPagingEnabled
    //is true, the page size has to be the bounds.width of the collectionview.
    //We want a portion of the next transaction to be visible, so we can use
    //a hidden scrollview with isPagingEnbabled=true, which forwards its scroll events
    //to the collectionview
    fileprivate let secretScrollView = UIScrollView()
    private var hasShownInitialIndex = false

    deinit {
        store.unsubscribe(self)
    }

    override func viewDidLoad() {
        
        view.addSubview(header)
        header.closeCallback = { [weak self] in
            guard let s = self else { return }
            self?.onDismiss(s)
        }
        
        header.constrain([
            header.topAnchor.constraint(equalTo: view.topAnchor, constant: E.isIPhoneX ? 70 : 20),
            header.leftAnchor.constraint(equalTo: view.leftAnchor),
            header.rightAnchor.constraint(equalTo: view.rightAnchor),
            header.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        collectionView?.register(TransactionDetailCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.contentInset = UIEdgeInsetsMake(C.padding[2], C.padding[2], C.padding[2], C.padding[2])
        setupScrolling()
        
        collectionView?.backgroundColor = .clear
        
        store.subscribe(self, selector: { $0.isBtcSwapped != $1.isBtcSwapped }, callback: { self.isBtcSwapped = $0.isBtcSwapped })
        store.subscribe(self, selector: { $0.currentRate != $1.currentRate }, callback: { self.rate = $0.currentRate })
        store.lazySubscribe(self, selector: { $0.walletState.transactions != $1.walletState.transactions }, callback: {
            self.transactions = $0.walletState.transactions
            self.collectionView?.reloadData()
        })
    }

    private func setupScrolling() {
        view.addSubview(secretScrollView)
        secretScrollView.isPagingEnabled = true

        //This scrollview needs to be off screen so that it doesn't block touches meant for the transaction details
        //card. We are just using this scrollview for its gesture recognizer, so that we can se a preview of the next card
        //and also have paging enabled for the scrollview.
        secretScrollView.frame = CGRect(x: C.padding[2] - 4.0, y: -1000, width: UIScreen.main.safeWidth - C.padding[3], height: UIScreen.main.bounds.height - C.padding[1])
        secretScrollView.showsHorizontalScrollIndicator = false
        secretScrollView.alwaysBounceHorizontal = true
        collectionView?.addGestureRecognizer(secretScrollView.panGestureRecognizer)
        collectionView?.panGestureRecognizer.isEnabled = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !hasShownInitialIndex {
            // collectionView.contentSize returns invalid sizes, so we have to use the flow layout contentSize
            guard let contentSize = collectionView?.collectionViewLayout.collectionViewContentSize else { return }
            guard let collectionView = collectionView else { return }
            
            secretScrollView.contentSize = CGSize(width: contentSize.width + C.padding[1], height: contentSize.height)
            
            var contentOffset = collectionView.contentOffset
            contentOffset.x += collectionView.contentInset.left
            contentOffset.y += collectionView.contentInset.top
            secretScrollView.contentOffset = contentOffset

            //The scrollview's delegate has to be set late here so we can set the initial position
            //without causing any side effects.
            secretScrollView.delegate = self

            hasShownInitialIndex = true
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !hasShownInitialIndex {
            collectionView?.scrollToItem(at: IndexPath(item: selectedIndex, section: 0), at: .centeredHorizontally, animated: false)
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let collectionView = collectionView else { return }
        guard scrollView == secretScrollView else { return }
        var contentOffset = scrollView.contentOffset
        contentOffset.x = contentOffset.x - collectionView.contentInset.left
        contentOffset.y = contentOffset.y - collectionView.contentInset.top
        collectionView.contentOffset = contentOffset
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - UICollectionViewDataSource
extension TransactionDetailsViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return transactions.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        //super.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)
        guard let transactionDetailCell = cell as? TransactionDetailCollectionViewCell else { return }

        transactionDetailCell.scrollView.contentOffset = CGPoint(x: 0, y: 0)
        transactionDetailCell.resetView()
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
        guard let transactionDetailCell = item as? TransactionDetailCollectionViewCell else { return item }
        guard let rate = rate else { return item }
        
        let transaction = transactions[indexPath.row]
        transaction.kvStore = kvStore
        
        transactionDetailCell.kvStore = kvStore
        
        transactionDetailCell.set(transaction: transaction, isBtcSwapped: isBtcSwapped, rate: rate, rates: store.state.rates, maxDigits: store.state.maxDigits)
        
        transactionDetailCell.closeCallback = { [weak self] in
            if let delegate = self?.transitioningDelegate as? ModalTransitionDelegate {
                delegate.reset()
            }
            self?.dismiss(animated: true, completion: nil)
        }
        
        transactionDetailCell.store = store

        if transactionDetailCell.didBeginEditing == nil {
            transactionDetailCell.didBeginEditing = { [weak self] in
                self?.secretScrollView.isScrollEnabled = false
                self?.collectionView?.isScrollEnabled = false
            }
        }

        if transactionDetailCell.didEndEditing == nil {
            transactionDetailCell.didEndEditing = { [weak self] in
                self?.secretScrollView.isScrollEnabled = true
                self?.collectionView?.isScrollEnabled = true
            }
        }

        if let modalTransitioningDelegate = transitioningDelegate as? ModalTransitionDelegate {
            transactionDetailCell.modalTransitioningDelegate = modalTransitioningDelegate
        }

        return transactionDetailCell
    }
}
