pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Sign is Ownable, ERC721 {
    struct Metadata {
        SignMonthData signData;
        string description;
    }

    struct SignMonthData {
        string sign;
        uint8 number;
        uint16 eclipticLength;
        string element;
        uint8 validFrom;
        uint8 validUntil;
        uint8 month;
        string planet;
    }

    mapping(uint8 => SignMonthData) signsByMonth;
    mapping(uint256 => Metadata) tokens;
    mapping(uint256 => bool) claimedTokens;

    string private _currentBaseURI;

    constructor() ERC721("Sign", "SIG") {
        setBaseURI("http://localhost:3333/token/");

        signsByMonth[4] = SignMonthData(
            "Aries",
            0,
            30,
            "Fogo",
            21,
            20,
            4,
            "Marte"
        );
        signsByMonth[5] = SignMonthData(
            "Touro",
            1,
            60,
            "Terra",
            21,
            20,
            5,
            "Venus"
        );
        signsByMonth[6] = SignMonthData(
            "Gemeos",
            2,
            90,
            "Ar",
            21,
            20,
            6,
            "Mercurio"
        );
        signsByMonth[7] = SignMonthData(
            "Cancer",
            3,
            120,
            "Agua",
            21,
            22,
            7,
            "Lua"
        );
        signsByMonth[8] = SignMonthData(
            "Leao",
            4,
            150,
            "Fogo",
            23,
            22,
            8,
            "Sol"
        );
        signsByMonth[9] = SignMonthData(
            "Virgem",
            5,
            180,
            "Terra",
            23,
            22,
            9,
            "Mercurio"
        );
        signsByMonth[10] = SignMonthData(
            "Libra",
            6,
            210,
            "Ar",
            23,
            22,
            10,
            "Venus"
        );
        signsByMonth[11] = SignMonthData(
            "Escorpiao",
            7,
            240,
            "Agua",
            23,
            21,
            11,
            "Plutao"
        );
        signsByMonth[12] = SignMonthData(
            "Sagitario",
            8,
            270,
            "Fogo",
            22,
            21,
            12,
            "Jupiter"
        );
        signsByMonth[1] = SignMonthData(
            "Capricornio",
            9,
            300,
            "Terra",
            22,
            19,
            1,
            "Saturno"
        );
        signsByMonth[2] = SignMonthData(
            "Aquario",
            10,
            330,
            "Ar",
            20,
            18,
            2,
            "Urano"
        );
        signsByMonth[3] = SignMonthData(
            "Peixes",
            11,
            360,
            "Agua",
            19,
            20,
            3,
            "Netuno"
        );
    }

    function setBaseURI(string memory baseURI) public onlyOwner {
        _currentBaseURI = baseURI;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _currentBaseURI;
    }

    function claim(string memory description) external payable {
        require(msg.value == 0.01 ether, "claiming a date costs 10 finney");

        (uint16 now_year, uint8 now_month, uint8 now_day) = timestampToDate(
            block.timestamp
        );
        uint256 tokenId = generateTokenId(now_year, now_month, now_day);

        if (claimedTokens[tokenId]) revert("token already claimed");

        SignMonthData memory signData;

        SignMonthData memory signInfo = signsByMonth[now_month];

        if (now_day > signInfo.validUntil) {
            signData = signsByMonth[now_month + 1];
        } else {
            signData = signInfo;
        }

        mint(signData, description, tokenId);
    }

    function generateTokenId(
        uint16 year,
        uint8 month,
        uint8 day
    ) internal pure returns (uint256) {
        uint256 tokenId = uint256(keccak256(abi.encode(year, month, day)));
        return tokenId;
    }

    function mint(
        SignMonthData memory signData,
        string memory description,
        uint256 tokenId
    ) internal {
        tokens[tokenId] = Metadata(signData, description);
        claimedTokens[tokenId] = true;
        _safeMint(msg.sender, tokenId);
    }

    function get(
        uint16 nowYear,
        uint8 nowMonth,
        uint8 nowDay
    )
        external
        view
        returns (
            string memory sign,
            uint8 number,
            uint16 eclipticLength,
            string memory element,
            uint8 validFrom,
            uint8 validUntil,
            uint8 month,
            string memory planet,
            string memory description
        )
    {
        uint256 id = generateTokenId(nowYear, nowMonth, nowDay);
        require(claimedTokens[id] == true, "token not claimed");
        Metadata memory token = tokens[id];
        sign = token.signData.sign;
        number = token.signData.number;
        eclipticLength = token.signData.eclipticLength;
        element = token.signData.element;
        validFrom = token.signData.validFrom;
        validUntil = token.signData.validUntil;
        month = token.signData.month;
        planet = token.signData.planet;
        description = token.description;
    }

    function transferToken(
        address tokenOwner,
        address tokenRecipient,
        uint256 tokenId,
        uint256 tokenValue
    ) external payable {
        require(
            msg.sender == tokenOwner,
            "you can't transfer a token that you not owns."
        );
        payable(tokenOwner).transfer(tokenValue);
        safeTransferFrom(tokenOwner, tokenRecipient, tokenId);
    }

    function descriptionOf(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        require(_exists(tokenId), "token not minted");
        Metadata memory sign = tokens[tokenId];
        return sign.description;
    }

    function descriptionOf(
        uint16 year,
        uint8 month,
        uint8 day
    ) public view returns (string memory) {
        require(_exists(generateTokenId(year, month, day)), "token not minted");
        Metadata memory sign = tokens[generateTokenId(year, month, day)];
        return sign.description;
    }

    function changeDescriptionOf(uint256 tokenId, string memory newDescription)
        public
    {
        require(
            ownerOf(tokenId) == msg.sender,
            "Only the owner of the token is allowed  to change the description."
        );
        require(_exists(tokenId), "Token not minted.");
        tokens[tokenId].description = newDescription;
    }

    function changeDescriptionOf(
        uint16 year,
        uint8 month,
        uint8 day,
        string memory newDescription
    ) public {
        uint256 tokenId = generateTokenId(year, month, day);
        require(
            ownerOf(tokenId) == msg.sender,
            "Only the owner of the token is allowed  to change the description."
        );
        require(_exists(tokenId), "Token not minted.");
        tokens[tokenId].description = newDescription;
    }

    function ownerOf(
        uint16 year,
        uint8 month,
        uint8 day
    ) public view returns (address) {
        return ownerOf(generateTokenId(year, month, day));
    }

    function timestampToDate(uint256 timestamp)
        public
        pure
        returns (
            uint16 year,
            uint8 month,
            uint8 day
        )
    {
        uint256 z = timestamp / 86400 + 719468;
        uint256 era = (z >= 0 ? z : z - 146096) / 146097;
        uint256 doe = z - era * 146097;
        uint256 yoe = (doe - doe / 1460 + doe / 36524 - doe / 146096) / 365;
        uint256 doy = doe - (365 * yoe + yoe / 4 - yoe / 100);
        uint256 mp = (5 * doy + 2) / 153;

        day = uint8(doy - (153 * mp + 2) / 5 + 1);
        month = mp < 10 ? uint8(mp + 3) : uint8(mp - 9);
        year = uint16(yoe + era * 400 + (month <= 2 ? 1 : 0));
    }
}
