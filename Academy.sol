// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract LazaroAcademy is Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _coursesMintedIds;
    Counters.Counter private _coursesPurchaseIds;
    Counters.Counter private _idOwnersCoursesPurchase;

    struct CourseMintTitle {
        uint256 id;
        string name;
        address ownerCourse_;
    }

    mapping(uint256 => CourseMintTitle) public getCourseMintedById;

    mapping(address => uint256) public getAlumsMinted;

    mapping(address => uint256) public getCourseId;

    mapping(uint256 => address) public getOwnersPurchaseById;

    mapping(uint256 => address) public getContractAddressById;

    function createCourseMinted(
        string memory nameOfCourse,
        address ownerCourse_
    ) public {
        _coursesMintedIds.increment();
        uint256 current = _coursesMintedIds.current();
        getCourseId[ownerCourse_] = current;
        getCourseMintedById[current] = CourseMintTitle(
            current,
            nameOfCourse,
            ownerCourse_
        );
    }

    function getCourseMinted(uint256 id)
        public
        view
        returns (CourseMintTitle memory)
    {
        return getCourseMintedById[id];
    }

    function getCourseByAddress(address owner) public view returns (uint256) {
        return getCourseId[owner];
    }

    function mintTitle(uint256 idCourse) public {
        CourseMintTitle memory owner_ = getCourseMintedById[idCourse];
        uint256 counter = getAlumsMinted[owner_.ownerCourse_];
        if (counter == 0) {
            getAlumsMinted[owner_.ownerCourse_] = 1;
        } else {
            getAlumsMinted[owner_.ownerCourse_] = counter + 1;
        }
    }

    function getQuantityAlumnsMinted(address ownerCourse)
        public
        view
        returns (uint256)
    {
        return getAlumsMinted[ownerCourse];
    }

    function withdraw() public payable onlyOwner {
        (bool os, ) = payable(owner()).call{value: address(this).balance}("");
        require(os);
    }

    function createCoursePurchase(string memory name) public {
        _idOwnersCoursesPurchase.increment();
        uint256 current = _idOwnersCoursesPurchase.current();
        getContractAddressById[current] = address(
            new CoursePurChase(current, owner(), name, msg.sender)
        );
    }
}

contract CoursePurChase is Ownable {
    modifier onlyOwnerAndCreator() {
        require(creador == msg.sender);
        _;
    }

    constructor(
        uint256 id_,
        address ownerFee_,
        string memory name,
        address creador_
    ) {
        courseId = id_;
        OwnerFee = ownerFee_;
        nameCourse = name;
        creador = creador_;
    }

    address public creador;
    address[] public alumns;
    address private OwnerFee;
    uint256 public courseId;
    string public nameCourse;

    function setAlumns(uint256 price) public payable {
        require(msg.value == price, "you don t have enough funds");
        alumns.push(msg.sender);
    }

    function getAlumns() public view returns (address[] memory) {
        return alumns;
    }

    function getId() public view returns (uint256) {
        return courseId;
    }

    function getName() public view returns (string memory) {
        return nameCourse;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function withdraw() public payable onlyOwnerAndCreator {
        (bool hs, ) = payable(OwnerFee).call{
            value: (address(this).balance * 7) / 100
        }("");
        require(hs);

        (bool os, ) = payable(creador).call{value: address(this).balance}("");
        require(os);
    }
}
