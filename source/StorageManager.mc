// ABOUTME: Manages flat key-value storage to work within 8KB limit
// ABOUTME: Provides methods for storing library metadata, books, collections

using Toybox.Application.Storage;
using Toybox.System;

class StorageManager {

    // Keys for storage
    const KEY_LIBRARY_SYNC = "library_last_sync";
    const KEY_COLLECTION_IDS = "collection_ids";
    const KEY_ALL_BOOK_IDS = "all_book_ids";
    const KEY_CURRENT_BOOK_ID = "current_book_id";

    function initialize() {
    }

    // --- Library Sync Timestamp ---

    function setLibrarySyncTime(timestamp) {
        Storage.setValue(KEY_LIBRARY_SYNC, timestamp);
    }

    function getLibrarySyncTime() {
        return Storage.getValue(KEY_LIBRARY_SYNC);
    }

    // --- Collections ---

    function setCollectionIds(collectionIds) {
        Storage.setValue(KEY_COLLECTION_IDS, collectionIds);
    }

    function getCollectionIds() {
        var ids = Storage.getValue(KEY_COLLECTION_IDS);
        return ids != null ? ids : [];
    }

    function setCollection(collectionId, collectionData) {
        var key = "collection_" + collectionId;
        Storage.setValue(key, collectionData);
    }

    function getCollection(collectionId) {
        var key = "collection_" + collectionId;
        return Storage.getValue(key);
    }

    function setBooksInCollection(collectionId, bookIds) {
        var key = "books_" + collectionId;
        Storage.setValue(key, bookIds);
    }

    function getBooksInCollection(collectionId) {
        var key = "books_" + collectionId;
        var ids = Storage.getValue(key);
        return ids != null ? ids : [];
    }

    // --- Books ---

    function setAllBookIds(bookIds) {
        Storage.setValue(KEY_ALL_BOOK_IDS, bookIds);
    }

    function getAllBookIds() {
        var ids = Storage.getValue(KEY_ALL_BOOK_IDS);
        return ids != null ? ids : [];
    }

    function setBook(bookId, bookData) {
        var key = "book_" + bookId;
        Storage.setValue(key, bookData);
    }

    function getBook(bookId) {
        var key = "book_" + bookId;
        return Storage.getValue(key);
    }

    // --- Current Book ---

    function setCurrentBookId(bookId) {
        Storage.setValue(KEY_CURRENT_BOOK_ID, bookId);
    }

    function getCurrentBookId() {
        return Storage.getValue(KEY_CURRENT_BOOK_ID);
    }

    // --- Utility ---

    function clearAllData() {
        Storage.clearValues();
    }

    function debugPrintStorage() {
        System.println("=== Storage Debug ===");
        System.println("Library sync: " + getLibrarySyncTime());
        System.println("Collection IDs: " + getCollectionIds());
        System.println("All book IDs: " + getAllBookIds());
        System.println("Current book: " + getCurrentBookId());
    }
}
