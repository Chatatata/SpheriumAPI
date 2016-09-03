defmodule SpheriumWebService.QuestionControllerTest do
  use SpheriumWebService.ConnCase

  alias SpheriumWebService.Question
  alias SpheriumWebService.Factory

  setup %{conn: conn} do
    {:ok, conn: conn}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, question_path(conn, :index)

    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    question = Factory.insert(:question)
    conn = get conn, question_path(conn, :show, question)

    assert json_response(conn, 200)["data"] == %{"id" => question.id,
                                                 "publisher_id" => question.publisher_id,
                                                 "user_id" => question.user_id}
  end

  test "renders page not found when question with given id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, question_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    publisher = Factory.insert(:publisher)
    conn = post conn, question_path(conn, :create), question: %{publisher_id: publisher.id, user_id: publisher.user_id}
    
    data = json_response(conn, 201)["data"]
    
    assert data["id"]
    assert Repo.get_by(Question, %{publisher_id: publisher.id, user_id: publisher.user_id})
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    publisher = Factory.insert(:publisher)
    conn = post conn, question_path(conn, :create), question: %{publisher_id: publisher.id}
    
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    question = Factory.insert(:question)
    conn = put conn, question_path(conn, :update, question), question: %{publisher_id: question.publisher_id, user_id: question.user_id}

    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Question, %{publisher_id: question.publisher_id, user_id: question.user_id})
  end
  
  test "throws 404 when non-existing identifier is given to update", %{conn: conn} do
    publisher = Factory.insert(:publisher)
    
    assert_error_sent 404, fn ->
      put conn, question_path(conn, :update, -1), question: %{publisher_id: publisher.id, user_id: publisher.user_id}
    end
  end

  test "deletes chosen resource", %{conn: conn} do
    question = Factory.insert(:question)
    conn = delete conn, question_path(conn, :delete, question)

    assert response(conn, 204)
    refute Repo.get(Question, question.id)
  end
  
  test "throws 404 when non-existing identifier is given to delete", %{conn: conn} do
    assert_error_sent 404, fn ->
      delete conn, question_path(conn, :delete, -1)
    end
  end
end
