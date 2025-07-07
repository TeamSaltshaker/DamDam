import UIKit

extension String {
    func highlight(query: String, foregroundColor: UIColor, font: UIFont) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(
            string: self,
            attributes: [
                .foregroundColor: foregroundColor,
                .font: font
            ]
        )

        let escapedQuery = NSRegularExpression.escapedPattern(for: query)
        guard let regex = try? NSRegularExpression(pattern: escapedQuery, options: .caseInsensitive) else {
            return attributedString
        }

        let matches = regex.matches(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count))

        for match in matches {
            attributedString.addAttribute(.foregroundColor, value: UIColor.appPrimary, range: match.range)
        }

        return attributedString
    }
}
