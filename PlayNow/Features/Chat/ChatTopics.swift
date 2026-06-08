import Foundation

struct ChatTopic: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let icon: String
    let systemPrompt: String
    let starter: String
}

enum ChatCatalog {
    static let topics: [ChatTopic] = [
        ChatTopic(
            id: "match_preview",
            title: "Match Preview",
            subtitle: "Pre-match analysis & key factors",
            icon: "soccerball",
            systemPrompt: "You are a senior football match analyst. Give clear, structured pre-match insights: key form, head-to-head, missing players, tactical edges. Always answer in English. Be concise: max 7 sentences. Never give 100% guarantees, frame everything as probabilistic.",
            starter: "Give me a brief framework for previewing any football match in 5 steps. Keep it practical."
        ),
        ChatTopic(
            id: "tactics_coach",
            title: "Tactics Coach",
            subtitle: "Formations, pressing, transitions",
            icon: "slider.horizontal.3",
            systemPrompt: "You are an expert football tactics coach. Explain formations, pressing schemes, build-up patterns, and counter-tactics with clarity. Answer in English. Max 7 sentences. Use simple examples when helpful.",
            starter: "Explain the difference between 4-3-3 high press and 5-4-1 mid-block in modern football."
        ),
        ChatTopic(
            id: "stats_advisor",
            title: "Stats & Probability",
            subtitle: "xG, value, model thinking",
            icon: "chart.bar",
            systemPrompt: "You are a football statistics advisor. Discuss xG, expected points, Poisson, value-based decisions, and bankroll discipline. Always answer in English. Max 7 sentences. Encourage responsible behavior — never promise wins.",
            starter: "What is xG and why is it more useful than recent goals scored?"
        ),
        ChatTopic(
            id: "bankroll",
            title: "Bankroll & Discipline",
            subtitle: "Risk control and unit sizing",
            icon: "function",
            systemPrompt: "You are a bankroll discipline coach for sports analytics. Talk about staking strategies, fixed unit sizing, Kelly fraction caveats, tilt control. Always answer in English. Max 7 sentences. Promote responsible play.",
            starter: "Walk me through a beginner-friendly fixed-unit staking plan."
        ),
        ChatTopic(
            id: "history",
            title: "Football History",
            subtitle: "Eras, legends, trivia",
            icon: "clock.arrow.circlepath",
            systemPrompt: "You are a football historian and storyteller. Explain key eras, legendary teams, iconic matches and players. Answer in English. Max 7 sentences. Be vivid yet accurate.",
            starter: "Tell me three most influential football tactical revolutions of the last 30 years."
        )
    ]

    static func topic(for id: String) -> ChatTopic {
        topics.first { $0.id == id } ?? topics[0]
    }
}
