public enum ReviewTokenBudget {
    public static let responseReserve = 900
    public static let framingReserve = 256
    public static func fits(inputTokens: Int, contextSize: Int) -> Bool {
        inputTokens >= 0 && contextSize >= responseReserve + framingReserve
            && inputTokens <= contextSize - responseReserve - framingReserve
    }
}
