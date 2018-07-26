defmodule Ephemeralist.UserControllerTest do 
  use EphemeralistWeb.ConnCase
  alias Ephemeralist.Accounts
  @create_attrs %{
    name: "some name", 
    username: "some_username",
    credential: %{
      email: "some_email@example.com",
      password: "Password1234"
    }
  }
  @invalid_user_attrs %{name: nil, username: nil}

  test "index/2 responds with all users", %{conn: conn} do 
    users = [%{name: "some name", username: "some user name"},
             %{name: "some other name", username: "some other username"}]

    [{:ok, user1}, {:ok, user2}] =
      Enum.map(users, fn u -> Accounts.create_user(u) end)

    response =
      conn
      |> get(user_path(conn, :index))
      |> json_response(200)

    expected = %{
      "data" => [
        %{"name" => user1.name, "username" => user1.username},
        %{"name" => user2.name, "username" => user2.username}
      ]
    }

    assert response == expected
  end 

  describe "show/2" do 
    setup [:create_user]

    test "Responds with user info if user is found", 
    %{conn: conn, user: user} 
    do 
      response = 
        conn
        |> get(user_path(conn, :show, user.id))
        |> json_response(200)

      expected = %{
        "data" => %{ "name" => user.name, "username" => user.username }
      }

      assert response == expected
    end 
    
    test "responds with a message indicating user not found", 
    %{conn: conn} 
    do 
      invalid_id = 1_000
      response = 
        conn
        |> get(user_path(conn, :show, invalid_id))
        |> json_response(404)

      expected = %{"errors" => %{"detail" => "user not found"}}

      assert response == expected
    end
  end 

  describe "create/2" do 
    test "should respond with user info and credentials if creation was successful",
    %{conn: conn}
    do 
      response = 
        conn
        |> post(user_path(conn, :create, @create_attrs))
        |> json_response(200)

      expected = %{
        "data" => %{
          "name" => @create_attrs.name, 
          "username" => @create_attrs.username
        }
      }

      assert response == expected
    end 

    test "responds with error message for invalid user info", 
    %{conn: conn}
    do 
      response = 
        conn 
        |> post(user_path(conn, :create, @invalid_user_attrs))
        |> json_response(422)

      expected = %{
        "errors" => %{
          "name" => ["can't be blank"],
          "username" => ["can't be blank"],
          "credential" => ["can't be blank"]
        }
      }

      assert response == expected
    end 
  end

  defp create_user(_) do 
    {:ok, user} = Accounts.create_user(@create_attrs)

    {:ok, user: user}
  end 
  
end 





