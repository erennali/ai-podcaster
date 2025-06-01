import Foundation
import RevenueCat
import Combine

protocol PaywallViewModelDelegate: AnyObject {
    func packagesDidLoad()
    func purchaseDidSucceed()
    func purchaseDidFail(with error: Error)
    func purchaseWasCancelled()
    func startLoading()
    func stopLoading()
    func restoreDidSucceed()
    func restoreDidFail(with error: Error)
    func offeringsLoadFailed(with error: Error)
}

final class PaywallViewModel {
    // MARK: - Properties
    private let iapService = IAPService.shared
    weak var delegate: PaywallViewModelDelegate?
    
    private var cancellables = Set<AnyCancellable>()
    
    var availablePackages: [Package] = [] {
        didSet {
            delegate?.packagesDidLoad()
        }
    }
    
    // For testing during development
    var hasMockPackages = false
    
    // MARK: - Init
    init() {
        setupBindings()
    }
    
    // MARK: - Public Methods
    func fetchOfferings() {
        delegate?.startLoading()
        
        iapService.fetchOfferings { [weak self] (offerings, error) in
            guard let self = self else { return }
            
            self.delegate?.stopLoading()
            
            if let error = error {
                print("Error fetching offerings: \(error.localizedDescription)")
                self.delegate?.offeringsLoadFailed(with: error)
                
                // In development, if RevenueCat isn't set up, use mock data
                #if DEBUG
                if self.shouldUseMockData() {
                    self.loadMockPackages()
                }
                #endif
                return
            }
            
            guard let currentOffering = offerings?.current else {
                print("No current offering available")
                
                // In development, if offerings are empty, use mock data
                #if DEBUG
                if self.shouldUseMockData() {
                    self.loadMockPackages()
                }
                #endif
                return
            }
            
            self.availablePackages = currentOffering.availablePackages
        }
    }
    
    func purchase(package: Package) {
        delegate?.startLoading()
        
        iapService.purchase(package: package) { [weak self] result in
            guard let self = self else { return }
            
            self.delegate?.stopLoading()
            
            switch result {
            case .success:
                self.delegate?.purchaseDidSucceed()
            case .failure(let error):
                // Check if the error is user cancellation
                let nsError = error as NSError
                if nsError.domain == "IAPService.Error" && nsError.code == 0 {
                    self.delegate?.purchaseWasCancelled()
                } else {
                    self.delegate?.purchaseDidFail(with: error)
                }
            }
        }
    }
    
    func restorePurchases() {
        delegate?.startLoading()
        
        iapService.restorePurchases { [weak self] result in
            guard let self = self else { return }
            
            self.delegate?.stopLoading()
            
            switch result {
            case .success:
                self.delegate?.restoreDidSucceed()
            case .failure(let error):
                self.delegate?.restoreDidFail(with: error)
            }
        }
    }
    
    // MARK: - Helper Methods
    func getFormattedPrice(for package: Package) -> String {
        return package.storeProduct.localizedPriceString
    }
    
    func getFormattedDuration(for package: Package) -> String {
        let identifier = package.identifier
        
        if identifier.lowercased().contains("monthly") {
            return "Aylık"
        } else if identifier.lowercased().contains("annual") || identifier.lowercased().contains("yearly") || identifier.lowercased().contains("lifetime") {
            return "Sınırsız"
        }
        
        return ""
    }
    
    // MARK: - Private Methods
    private func setupBindings() {
        // Use Combine to listen for offerings changes
        iapService.$offerings
            .compactMap { $0?.current?.availablePackages }
            .sink { [weak self] packages in
                if !packages.isEmpty {
                    self?.availablePackages = packages
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Development Testing Helpers
    #if DEBUG
    private func shouldUseMockData() -> Bool {
        // Add your conditions here to determine if mock data should be used
        // For example, if in development environment or if a debug flag is set
        return true
    }
    
    private func loadMockPackages() {
        print("Using mock packages for development")
        // Create mock packages with sample data
        // Note: This is for UI testing only, real purchases won't work
        
        // This is just a placeholder implementation
        // Real implementation would depend on your specific UI needs
        self.hasMockPackages = true
        
        // Notify delegate that packages are loaded (even though they're mock)
        self.delegate?.packagesDidLoad()
    }
    #endif
} 