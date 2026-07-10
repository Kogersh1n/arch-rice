pragma Singleton
import QtQuick


QtObject {
    id: backendRoot

    property var mangaList: []
    property bool isLoading: false

    function loadMockData() {
        isLoading = true

        mangaList = [
            { id: "solo", title: "Solo Leveling", coverUrl: "https://cdn.myanimelist.net/images/manga/3/252739l.jpg" },
            { id: "bers", title: "Berserk", coverUrl: "https://cdn.myanimelist.net/images/manga/1/157897l.jpg" },
            { id: "one", title: "One Piece", coverUrl: "https://cdn.myanimelist.net/images/manga/2/253146l.jpg" },
            { id: "csm", title: "Chainsaw Man", coverUrl: "https://cdn.myanimelist.net/images/manga/3/216464l.jpg" },
            { id: "vaga", title: "Vagabond", coverUrl: "https://cdn.myanimelist.net/images/manga/1/259070l.jpg" }
        ]
        

        isLoading = false
    }

}