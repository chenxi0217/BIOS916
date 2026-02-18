import Foundation
import Vision
import AppKit

let path = "/Users/chais/Documents/CodeX/BIOS916/orgchart.png"
let url = URL(fileURLWithPath: path)

guard let image = NSImage(contentsOf: url) else {
    fputs("failed to load image\n", stderr)
    exit(1)
}

var rect = NSRect(origin: .zero, size: image.size)
guard let cgImage = image.cgImage(forProposedRect: &rect, context: nil, hints: nil) else {
    fputs("failed to get cgImage\n", stderr)
    exit(1)
}

let request = VNRecognizeTextRequest()
request.recognitionLevel = .accurate
request.usesLanguageCorrection = true
request.recognitionLanguages = ["en-US"]

let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
do {
    try handler.perform([request])
    guard let observations = request.results else {
        print("no results")
        exit(0)
    }
    let sorted = observations.sorted { a, b in
        if abs(a.boundingBox.midY - b.boundingBox.midY) > 0.02 {
            return a.boundingBox.midY > b.boundingBox.midY
        }
        return a.boundingBox.minX < b.boundingBox.minX
    }
    for obs in sorted {
        if let candidate = obs.topCandidates(1).first {
            print(candidate.string)
        }
    }
} catch {
    fputs("OCR error: \(error)\n", stderr)
    exit(1)
}
