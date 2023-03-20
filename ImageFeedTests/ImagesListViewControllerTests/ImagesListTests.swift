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
    
    func testPresenterCalledDidUpdatePhotosAnimated() {
        let viewController = ImagesListViewControllerSpy()
        let service = ImagesListServiceSpy()
        let presenter = ImagesListPresenter(helper: ImagesListCellHelper(), imagesListService: service)
        
        presenter.view = viewController
        viewController.presenter = presenter
        
        presenter.requestFetchPhotosNextPage()
        
        XCTAssertTrue(viewController.didUpdatePhotosAnimatedCalled)
    }
    
    func testPresenterCalledDidUpdatePhotosAnimatedWhenPhotosEmpty() {
        let viewController = ImagesListViewControllerSpy()
        let service = ImagesListServiceSpy()
        let presenter = ImagesListPresenter(helper: ImagesListCellHelper(), imagesListService: service)
        
        presenter.view = viewController
        viewController.presenter = presenter
        
        presenter.viewDidLoad()
        
        XCTAssertTrue(viewController.didUpdatePhotosAnimatedCalled)
    }
    
    func testPresenterRequestChangeLike() {
        let service = ImagesListServiceSpy()
        let presenter = ImagesListPresenter(helper: ImagesListCellHelper(), imagesListService: service)

        let expectedIsLiked = true
        let cellIndexPath = IndexPath(row: 0, section: 0)

        presenter.requestFetchPhotosNextPage()
        presenter.requestChangeCellLike(at: cellIndexPath, isLike: expectedIsLiked)

        let actualPhoto = presenter.photos.first
        let actualIsLiked = actualPhoto?.isLiked

        XCTAssertEqual(expectedIsLiked, actualIsLiked)
    }
    
    func testPresenterDidNotCalledRequestFetchPhotosNextPageIfLastCell() {
        let service = ImagesListServiceSpy()
        let presenter = ImagesListPresenter(helper: ImagesListCellHelper(), imagesListService: service)
        let notLastIndexPath = IndexPath(row: 1, section: 0)
        
        let dummyPhotos = [
            Photo(
                id: "123",
                size: CGSize(width: 100, height: 100),
                createdAt: nil,
                welcomeDescription: nil,
                thumbImageURL: "nil",
                largeImageURL: "nil",
                isLiked: false),
            Photo(
                id: "1234",
                size: CGSize(width: 100, height: 100),
                createdAt: nil,
                welcomeDescription: nil,
                thumbImageURL: "nil",
                largeImageURL: "nil",
                isLiked: false),
            Photo(
                id: "12345",
                size: CGSize(width: 100, height: 100),
                createdAt: nil,
                welcomeDescription: nil,
                thumbImageURL: "nil",
                largeImageURL: "nil",
                isLiked: false),
        ]
        presenter.photos.append(contentsOf: dummyPhotos)
        
        presenter.requestFetchPhotosNextPageIfLastCell(at: notLastIndexPath)
        
        XCTAssertFalse(service.didCalledFetchPhotosNextPage)
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
