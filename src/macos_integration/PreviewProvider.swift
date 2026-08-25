import CxxStdlib
import PDFKit
import PreviewProviderCpp
import QuickLookUI
import os.log

enum PreviewError: Error {
    case previewDataEmpty
    case createPdfFailed
    case getPdfFirstPageFailed
}

class PreviewProvider: QLPreviewProvider, QLPreviewingController {
    let logger = Logger()

    func providePreview(for request: QLFilePreviewRequest) async throws -> QLPreviewReply {
        // Turned this off for now, see below.
//        logger.info("Generating preview for file: \(request.fileURL.path, privacy: .public)")

        await MainActor.run {
            PreviewProviderCxx.initIfNeeded()
        }

        let previewDataCpp = PreviewProviderCxx.getPdfPreviewData(std.string(request.fileURL.path))

        guard !previewDataCpp.empty() else {
            logger.error("Failed to generate preview data")
            throw PreviewError.previewDataEmpty
        }

        let previewData = Data(previewDataCpp)

        guard let pdfDocument = PDFDocument(data: previewData) else {
            logger.error("Failed to create PDF document")
            throw PreviewError.createPdfFailed
        }

        guard let firstPage = pdfDocument.page(at: 0) else {
            logger.error("Failed to get first page of PDF document")
            throw PreviewError.getPdfFirstPageFailed
        }

        let pageSize = firstPage.bounds(for: .mediaBox).size
        
        // This is all simply broken. Perhaps a newer Xcode is needed,
        // but we're running 26.3, which was released 26 Feb 2026, it's
        // now 20 Aug 2026, it's not even seven months old.
//        let message = "Generating preview for file: \(request.fileURL.path)"
//        logger.info(message as NSString)      // can't be done.
//        logger.info(message as OSLogMessage)  // also can't be done.

//        logger.info(
//            "Preview generated successfully with page size: \(pageSize.width, privacy: .public)x\(pageSize.height, privacy: .public)"
//        )
    
        return QLPreviewReply(forPDFWithPageSize: pageSize) { _ in pdfDocument }
    }
}
