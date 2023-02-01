import UIKit
import SnapKit
import SettingsViewController

class ViewController: UIViewController {

    enum Error: Swift.Error {
        case commandQueueCreationFailed
    }
    
    // MARK: - Properties
    
    private let picker = UIImagePickerController()
    private let settings = SettingsTableViewController()
    private let imageView: UIImageView
    
    private let device: MTLDevice
    private let commandQueue: MTLCommandQueue
    private let textureManager: TextureManager
    private let shadersContext: ShaderContext
    private var texturePair: (source: MTLTexture, destination: MTLTexture)?
    private var temporaryTexture: MTLTexture?

    // MARK: - Init

    init(device: MTLDevice) throws {
        let library = try device.makeDefaultLibrary(bundle: .main)
        guard let commandQueue = device.makeCommandQueue() else {
            throw Error.commandQueueCreationFailed
        }
        self.device = device
        self.commandQueue = commandQueue
        self.imageView = .init()
        self.shadersContext = try ShaderContext(library: library, device: device ,defaultValues: [])
        self.textureManager = .init(device: device)
        super.init(nibName: nil, bundle: nil)
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        self.setupTitle()
        self.setupSettings()
        self.setupUI()
    }

    // MARK: - Life Cycle

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    // MARK: - Actions

    @objc
    private func share() {
        guard let image = self.imageView.image
        else { return }

        let vc = UIActivityViewController(activityItems: [image],
                                          applicationActivities: nil)
        self.present(vc, animated: true)
    }

    @objc
    private func pickImage() {
        let alert = UIAlertController(title: "Select source",
                                      message: nil,
                                      preferredStyle: .actionSheet)
        alert.addAction(.init(title: "Camera", style: .default) { _ in
            self.picker.sourceType = .camera
            self.present(self.picker, animated: true)
        })
        alert.addAction(.init(title: "Library", style: .default) { _ in
            self.picker.sourceType = .photoLibrary
            self.present(self.picker, animated: true)
        })
        alert.addAction(.init(title: "Cancel",
                              style: .destructive) { _ in })
        self.present(alert, animated: true)
    }
    
    func handlePickedImage(image: UIImage) {
        guard let cgImage = image.cgImage,
              let source = try? self.textureManager.texture(from: cgImage),
              let destination = try? self.textureManager.matchingTexture(to: source),
              let temporaryDestination = try? self.textureManager.matchingTexture(to: source)
        else { return }
        
        self.texturePair = (source, destination)
        self.temporaryTexture = temporaryDestination
        self.imageView.image = image
        self.redraw()
    }
    
    // MARK: - Private Methods
    
    private func redraw() {
        guard let source = self.texturePair?.source,
              let destination = self.texturePair?.destination,
              let commandBuffer = self.commandQueue.makeCommandBuffer(),
              let temporaryTexture = self.temporaryTexture
        else { return }

        self.shadersContext.encode(source: source,
                                destination: destination,
                                temporaryDestination: temporaryTexture,
                                in: commandBuffer)

        commandBuffer.addCompletedHandler { _ in
            guard let cgImage = try? self.textureManager.cgImage(from: destination)
            else { return }

            DispatchQueue.main.async {
                self.imageView.image = UIImage(cgImage: cgImage)
            }
        }
        commandBuffer.commit()
    }
    
    private func setupTitle(){
        self.picker.delegate = self
        self.view.backgroundColor = .systemBackground
        
        self.title = "image editor demo"
        self.navigationItem.leftBarButtonItem = .init(barButtonSystemItem: .camera,
                                                      target: self,
                                                      action: #selector(self.pickImage))
        self.navigationItem.rightBarButtonItems = [
            .init(barButtonSystemItem: .action,
                  target: self,
                  action: #selector(self.share))
        ]
    }
    
    private func setupUI() {
        guard let settingsView = self.settings.view
        else { return }
        self.addChild(self.settings)
        self.view.addSubview(settingsView)
        settingsView.snp.makeConstraints {
            $0.left.right.equalTo(self.view.safeAreaLayoutGuide)
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(20)
            $0.height.equalTo(self.view.snp.height).dividedBy(2)
        }
        
        // image view

        self.imageView.contentMode = .scaleAspectFit
        self.imageView.layer.cornerRadius = 10
        self.imageView.layer.masksToBounds = true
        self.view.addSubview(self.imageView)
        self.imageView.backgroundColor = .tertiarySystemFill
        self.imageView.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(20)
            $0.top.equalTo(self.view.safeAreaLayoutGuide).inset(20)
            $0.bottom.equalTo(settingsView.snp.top).inset(-20)
        }
    }
    
    private func setupSettings() {
        self.settings.settings = [
            FloatSetting(name: "Temperature",
                         defaultValue: .zero,
                         min: -1,
                         max: 1) {
                             self.shadersContext.add(.temperature($0))
                             self.redraw()
            },
            FloatSetting(name: "Tint",
                         defaultValue: .zero,
                         min: -1,
                         max: 1) {
                             self.shadersContext.add(.tint($0))
                self.redraw()
            },
            FloatSetting(name: "Brightness",
                         defaultValue: .zero,
                         min: -1,
                         max: 1) {
                             self.shadersContext.add(.brightness($0))
                self.redraw()
            },
            FloatSetting(name: "Contrast",
                         defaultValue: .zero,
                         min: -128,
                         max: 128) {
                             self.shadersContext.add(.contrast($0))
                self.redraw()
            },
            FloatSetting(name: "Saturation",
                         defaultValue: .zero,
                         min: -1,
                         max: 1) {
                             self.shadersContext.add(.saturation($0))
                self.redraw()
            },
            FloatSetting(name: "Blur",
                         defaultValue: .zero,
                         min: .zero,
                         max: 3){
                             self.shadersContext.add(.blur($0))
                             self.redraw()
                         },
            BoolSetting(name: "Black&White Filter",
                        initialValue: false) {
                            self.shadersContext.add(.bw($0))
                self.redraw()
            },
        ]
    }
}
