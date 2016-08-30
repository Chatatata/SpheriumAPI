defmodule SpheriumWebService.QuestionView do
  use SpheriumWebService.Web, :view

  def render("index.json", %{questions: questions}) do
    %{data: render_many(questions, SpheriumWebService.QuestionView, "question.json")}
  end

  def render("show.json", %{question: question}) do
    %{data: render_one(question, SpheriumWebService.QuestionView, "question.json")}
  end

  def render("question.json", %{question: question}) do
    %{id: question.id,
      publisher_id: question.publisher_id,
      user_id: question.user_id}
  end
end
