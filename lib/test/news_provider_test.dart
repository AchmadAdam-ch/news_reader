test('Should update error message when fetching news fails', () async {
  // Arrange
  when(mockRepository.getTopHeadlines())
      .thenThrow(NewsException('Network Error'));

  // Act
  await provider.fetchTopHeadlines();

  // Assert
  expect(provider.errorMessage, contains('Network Error'));
  expect(provider.isLoading, false);
});