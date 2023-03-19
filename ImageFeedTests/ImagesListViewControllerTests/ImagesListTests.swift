//
//  ImagesListTests.swift
//  ImageFeedTests
//
//  Created by Александр Бекренев on 17.03.2023.
//

@testable import ImageFeed
import XCTest

final class ImagesListTests: XCTestCase {
    private let photoWidth: CGFloat = 100
    private let photoHeight: CGFloat = 100
    private let tableViewWidth: CGFloat = 400
    
    func testViewControllerCallsViewDidLoad() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController
        let presenter = ImagesListPresenterSpy()
        viewController.configure(presenter: presenter)
        
        _ = viewController.view
        
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testHelperCalculateCellHeight() {
        let helper = ImagesListCellHelper()
        let testPhoto = Photo(
            id: "123",
            size: CGSize(width: photoWidth, height: photoHeight),
            createdAt: nil,
            welcomeDescription: nil,
            thumbImageURL: "nil",
            largeImageURL: "nil",
            isLiked: false)
        
        let expectedHeight = calculateExpectedCellHeight()
        let actualHeight = helper.calculateCellHeight(
            tableViewWidth: tableViewWidth,
            for: testPhoto)
        
        XCTAssertEqual(expectedHeight, actualHeight)
    }
    
    func testPresenterSetCellLoadingState() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController
        let presenter = ImagesListPresenter(helper: ImagesListCellHelper())
        
        _ = viewController.view

        let cell = viewController.tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier) as! ImagesListCell
        
        presenter.setCellLoadingStateIfItsImageNil(cell)
        let actualCellState = cell.cellState
        
        XCTAssertTrue(actualCellState == ImagesListCell.FeedCellImageState.loading)
    }
    
    func testHelperSetImageForCellAndItsStateFinished() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController
        let helper = ImagesListCellHelper()
        let imageLoader = ImagesListCellImageLoaderStub()
        let dummyPhoto = Photo(
            id: "123",
            size: CGSize(width: photoWidth, height: photoHeight),
            createdAt: nil,
            welcomeDescription: nil,
            thumbImageURL: "nil",
            largeImageURL: "nil",
            isLiked: false)
        
        helper.imageLoader = imageLoader
        imageLoader.helper = helper
        
        _ = viewController.view
        
        let cell = viewController.tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier) as! ImagesListCell
        
        let configuredCell = helper.configured(
            cell: cell,
            with: dummyPhoto,
            completion: { () in })
        
        let expectedImage = UIImage(systemName: "person.crop.circle")!
        let expectedState = ImagesListCell.FeedCellImageState.finished(expectedImage)
        
        XCTAssertEqual(configuredCell.cellImage, expectedImage)
        XCTAssertEqual(configuredCell.cellState, expectedState)
    }
}

extension ImagesListTests {
    func calculateExpectedCellHeight() -> CGFloat {
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableViewWidth - imageInsets.left - imageInsets.right
        let imageWidth = photoWidth
        let scale = imageViewWidth / imageWidth
        let cellHeight = photoHeight * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
}
