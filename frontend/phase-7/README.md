# Phase 7: Rating & Review System

## 📋 Overview

Implementasi sistem rating dan review dengan interface 1-5 bintang untuk semua layanan kolam renang.

## 🎯 Objectives

- Rating interface (1-5 stars)
- Review submission forms
- Review display interface
- Rating analytics
- Staff rating interface
- Review moderation

## 📁 Files Structure

```
phase-7/
├── 01-rating-interface.md
├── 02-review-submission.md
├── 03-review-display.md
├── 04-rating-analytics.md
└── 05-review-moderation.md
```

## 🔧 Implementation Points

### Point 1: Rating Interface

**Subpoints:**

- Star rating component
- Rating submission
- Rating validation
- Rating display
- Rating statistics
- Rating history

**Files:**

- `components/rating/StarRating.tsx`
- `components/rating/RatingForm.tsx`
- `components/rating/RatingDisplay.tsx`
- `components/rating/RatingStats.tsx`
- `hooks/useRating.ts`
- `lib/rating-utils.ts`

### Point 2: Review Submission

**Subpoints:**

- Review form component
- Review validation
- Review submission
- Review confirmation
- Review editing
- Review deletion

**Files:**

- `components/review/ReviewForm.tsx`
- `components/review/ReviewSubmission.tsx`
- `components/review/ReviewConfirmation.tsx`
- `components/review/ReviewEdit.tsx`
- `hooks/useReview.ts`
- `lib/review-utils.ts`

### Point 3: Review Display

**Subpoints:**

- Review list component
- Review card component
- Review filtering
- Review sorting
- Review pagination
- Review search

**Files:**

- `components/review/ReviewList.tsx`
- `components/review/ReviewCard.tsx`
- `components/review/ReviewFilter.tsx`
- `components/review/ReviewSort.tsx`
- `hooks/useReviewDisplay.ts`
- `lib/review-display-utils.ts`

### Point 4: Rating Analytics

**Subpoints:**

- Rating charts
- Rating trends
- Rating comparison
- Rating insights
- Rating reports
- Rating export

**Files:**

- `components/analytics/RatingCharts.tsx`
- `components/analytics/RatingTrends.tsx`
- `components/analytics/RatingComparison.tsx`
- `components/analytics/RatingInsights.tsx`
- `hooks/useRatingAnalytics.ts`
- `lib/analytics-utils.ts`

### Point 5: Review Moderation

**Subpoints:**

- Review moderation interface
- Review approval
- Review rejection
- Review flagging
- Review reports
- Review management

**Files:**

- `components/moderation/ReviewModeration.tsx`
- `components/moderation/ReviewApproval.tsx`
- `components/moderation/ReviewRejection.tsx`
- `components/moderation/ReviewFlagging.tsx`
- `hooks/useReviewModeration.ts`
- `lib/moderation-utils.ts`

## 📦 Dependencies

### Rating & Review Dependencies

```json
{
  "react-rating": "^2.0.0",
  "react-hook-form": "^7.48.0",
  "zod": "^3.22.0",
  "@hookform/resolvers": "^3.3.0",
  "recharts": "^2.8.0",
  "date-fns": "^2.30.0"
}
```

### UI Dependencies

```json
{
  "@headlessui/react": "^1.7.0",
  "@heroicons/react": "^2.0.0",
  "clsx": "^2.0.0",
  "tailwind-merge": "^2.0.0",
  "lucide-react": "^0.294.0",
  "react-textarea-autosize": "^8.5.0"
}
```

### State Management

```json
{
  "zustand": "^4.4.0",
  "react-query": "^3.39.0",
  "react-hot-toast": "^2.4.0"
}
```

## 🎨 Component Examples

### Star Rating Component

```typescript
import { useState } from "react";
import { Star } from "lucide-react";

interface StarRatingProps {
  rating: number;
  onRatingChange?: (rating: number) => void;
  readonly?: boolean;
  size?: "sm" | "md" | "lg";
  showLabel?: boolean;
}

export const StarRating = ({
  rating,
  onRatingChange,
  readonly = false,
  size = "md",
  showLabel = true,
}: StarRatingProps) => {
  const [hoverRating, setHoverRating] = useState(0);

  const sizeClasses = {
    sm: "w-4 h-4",
    md: "w-6 h-6",
    lg: "w-8 h-8",
  };

  const handleStarClick = (starRating: number) => {
    if (!readonly && onRatingChange) {
      onRatingChange(starRating);
    }
  };

  const handleStarHover = (starRating: number) => {
    if (!readonly) {
      setHoverRating(starRating);
    }
  };

  const handleStarLeave = () => {
    if (!readonly) {
      setHoverRating(0);
    }
  };

  const getStarColor = (starIndex: number) => {
    const currentRating = hoverRating || rating;
    return starIndex <= currentRating ? "text-yellow-400" : "text-gray-300";
  };

  const getRatingLabel = (rating: number) => {
    const labels = {
      1: "Poor",
      2: "Fair",
      3: "Good",
      4: "Very Good",
      5: "Excellent",
    };
    return labels[rating as keyof typeof labels] || "";
  };

  return (
    <div className="flex items-center space-x-1">
      {[1, 2, 3, 4, 5].map((star) => (
        <button
          key={star}
          type="button"
          disabled={readonly}
          onClick={() => handleStarClick(star)}
          onMouseEnter={() => handleStarHover(star)}
          onMouseLeave={handleStarLeave}
          className={`${sizeClasses[size]} ${getStarColor(star)} ${
            !readonly
              ? "hover:scale-110 transition-transform cursor-pointer"
              : "cursor-default"
          }`}
        >
          <Star className="w-full h-full fill-current" />
        </button>
      ))}
      {showLabel && rating > 0 && (
        <span className="ml-2 text-sm text-gray-600">
          {getRatingLabel(rating)}
        </span>
      )}
    </div>
  );
};
```

### Rating Form Component

```typescript
import { useState } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { ratingSchema } from "@/lib/validations/rating";
import { StarRating } from "./StarRating";
import { Textarea } from "@/components/ui/textarea";

interface RatingFormProps {
  serviceType: "pool" | "cafe" | "staff" | "facility";
  serviceId: string;
  onSuccess: (rating: Rating) => void;
}

export const RatingForm = ({
  serviceType,
  serviceId,
  onSuccess,
}: RatingFormProps) => {
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [overallRating, setOverallRating] = useState(0);
  const [componentRatings, setComponentRatings] = useState({
    cleanliness: 0,
    service: 0,
    value: 0,
    atmosphere: 0,
  });

  const {
    register,
    handleSubmit,
    formState: { errors },
    reset,
  } = useForm({
    resolver: zodResolver(ratingSchema),
  });

  const onSubmit = async (data: RatingFormData) => {
    setIsSubmitting(true);
    try {
      const rating = await submitRating({
        service_type: serviceType,
        service_id: serviceId,
        overall_rating: overallRating,
        component_ratings: componentRatings,
        review_text: data.review_text,
        is_anonymous: data.is_anonymous,
      });

      onSuccess(rating);
      reset();
      setOverallRating(0);
      setComponentRatings({
        cleanliness: 0,
        service: 0,
        value: 0,
        atmosphere: 0,
      });
      toast.success("Rating submitted successfully!");
    } catch (error) {
      toast.error("Failed to submit rating");
    } finally {
      setIsSubmitting(false);
    }
  };

  const getServiceTitle = () => {
    const titles = {
      pool: "Swimming Pool",
      cafe: "Cafe Service",
      staff: "Staff Service",
      facility: "Facility",
    };
    return titles[serviceType];
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
      <div className="text-center">
        <h3 className="text-lg font-semibold mb-2">Rate {getServiceTitle()}</h3>
        <p className="text-gray-600">
          Help us improve by sharing your experience
        </p>
      </div>

      {/* Overall Rating */}
      <div className="text-center">
        <label className="block text-sm font-medium text-gray-700 mb-2">
          Overall Rating
        </label>
        <StarRating
          rating={overallRating}
          onRatingChange={setOverallRating}
          size="lg"
          showLabel={true}
        />
      </div>

      {/* Component Ratings */}
      <div className="space-y-4">
        <h4 className="font-medium text-gray-900">Rate Specific Aspects</h4>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div className="flex items-center justify-between">
            <span className="text-sm font-medium text-gray-700">
              Cleanliness
            </span>
            <StarRating
              rating={componentRatings.cleanliness}
              onRatingChange={(rating) =>
                setComponentRatings((prev) => ({
                  ...prev,
                  cleanliness: rating,
                }))
              }
              size="sm"
            />
          </div>

          <div className="flex items-center justify-between">
            <span className="text-sm font-medium text-gray-700">
              Service Quality
            </span>
            <StarRating
              rating={componentRatings.service}
              onRatingChange={(rating) =>
                setComponentRatings((prev) => ({ ...prev, service: rating }))
              }
              size="sm"
            />
          </div>

          <div className="flex items-center justify-between">
            <span className="text-sm font-medium text-gray-700">
              Value for Money
            </span>
            <StarRating
              rating={componentRatings.value}
              onRatingChange={(rating) =>
                setComponentRatings((prev) => ({ ...prev, value: rating }))
              }
              size="sm"
            />
          </div>

          <div className="flex items-center justify-between">
            <span className="text-sm font-medium text-gray-700">
              Atmosphere
            </span>
            <StarRating
              rating={componentRatings.atmosphere}
              onRatingChange={(rating) =>
                setComponentRatings((prev) => ({ ...prev, atmosphere: rating }))
              }
              size="sm"
            />
          </div>
        </div>
      </div>

      {/* Review Text */}
      <div>
        <label
          htmlFor="review_text"
          className="block text-sm font-medium text-gray-700 mb-2"
        >
          Write a Review (Optional)
        </label>
        <Textarea
          id="review_text"
          {...register("review_text")}
          placeholder="Share your experience and help others..."
          rows={4}
          className="w-full"
        />
        {errors.review_text && (
          <p className="mt-1 text-sm text-red-600">
            {errors.review_text.message}
          </p>
        )}
      </div>

      {/* Anonymous Option */}
      <div className="flex items-center">
        <input
          type="checkbox"
          id="is_anonymous"
          {...register("is_anonymous")}
          className="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
        />
        <label
          htmlFor="is_anonymous"
          className="ml-2 block text-sm text-gray-700"
        >
          Submit anonymously
        </label>
      </div>

      {/* Submit Button */}
      <button
        type="submit"
        disabled={isSubmitting || overallRating === 0}
        className="w-full bg-blue-600 text-white py-3 px-4 rounded-md hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed"
      >
        {isSubmitting ? "Submitting..." : "Submit Rating"}
      </button>
    </form>
  );
};
```

### Review List Component

```typescript
import { useState } from "react";
import { useReviewDisplay } from "@/hooks/useReviewDisplay";
import { ReviewCard } from "./ReviewCard";
import { ReviewFilter } from "./ReviewFilter";
import { ReviewSort } from "./ReviewSort";

interface ReviewListProps {
  serviceType: "pool" | "cafe" | "staff" | "facility";
  serviceId: string;
}

export const ReviewList = ({ serviceType, serviceId }: ReviewListProps) => {
  const [filter, setFilter] = useState("all");
  const [sortBy, setSortBy] = useState("newest");
  const [search, setSearch] = useState("");

  const { reviews, isLoading, pagination, stats } = useReviewDisplay({
    serviceType,
    serviceId,
    filter,
    sortBy,
    search,
  });

  if (isLoading) {
    return (
      <div className="space-y-4">
        {[1, 2, 3].map((i) => (
          <div
            key={i}
            className="animate-pulse bg-gray-200 rounded-lg h-32"
          ></div>
        ))}
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Review Stats */}
      <div className="bg-white rounded-lg p-6 border">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
          <div className="text-center">
            <div className="text-2xl font-bold text-blue-600">
              {stats.averageRating}
            </div>
            <div className="text-sm text-gray-600">Average Rating</div>
          </div>
          <div className="text-center">
            <div className="text-2xl font-bold text-green-600">
              {stats.totalReviews}
            </div>
            <div className="text-sm text-gray-600">Total Reviews</div>
          </div>
          <div className="text-center">
            <div className="text-2xl font-bold text-yellow-600">
              {stats.positiveReviews}
            </div>
            <div className="text-sm text-gray-600">Positive Reviews</div>
          </div>
          <div className="text-center">
            <div className="text-2xl font-bold text-purple-600">
              {stats.recentReviews}
            </div>
            <div className="text-sm text-gray-600">This Month</div>
          </div>
        </div>
      </div>

      {/* Filters and Search */}
      <div className="flex flex-col sm:flex-row gap-4">
        <div className="flex-1">
          <input
            type="text"
            placeholder="Search reviews..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full px-3 py-2 border rounded-md"
          />
        </div>
        <ReviewFilter
          value={filter}
          onChange={setFilter}
          options={[
            { value: "all", label: "All Reviews" },
            { value: "5", label: "5 Stars" },
            { value: "4", label: "4 Stars" },
            { value: "3", label: "3 Stars" },
            { value: "2", label: "2 Stars" },
            { value: "1", label: "1 Star" },
          ]}
        />
        <ReviewSort
          value={sortBy}
          onChange={setSortBy}
          options={[
            { value: "newest", label: "Newest First" },
            { value: "oldest", label: "Oldest First" },
            { value: "highest", label: "Highest Rating" },
            { value: "lowest", label: "Lowest Rating" },
            { value: "most_helpful", label: "Most Helpful" },
          ]}
        />
      </div>

      {/* Reviews List */}
      <div className="space-y-4">
        {reviews.length === 0 ? (
          <div className="text-center py-12">
            <div className="text-gray-500 text-lg">No reviews found</div>
            <p className="text-gray-400 mt-2">
              Be the first to leave a review!
            </p>
          </div>
        ) : (
          reviews.map((review) => (
            <ReviewCard key={review.id} review={review} />
          ))
        )}
      </div>

      {/* Pagination */}
      {pagination && (
        <div className="flex justify-center">
          <Pagination
            currentPage={pagination.current_page}
            totalPages={pagination.last_page}
            onPageChange={(page) => pagination.setPage(page)}
          />
        </div>
      )}
    </div>
  );
};
```

### Review Card Component

```typescript
import { useState } from "react";
import { StarRating } from "./StarRating";
import { ThumbsUp, ThumbsDown, Flag, Reply } from "lucide-react";

interface ReviewCardProps {
  review: Review;
}

export const ReviewCard = ({ review }: ReviewCardProps) => {
  const [isLiked, setIsLiked] = useState(false);
  const [isDisliked, setIsDisliked] = useState(false);
  const [showReply, setShowReply] = useState(false);

  const handleLike = async () => {
    if (isDisliked) {
      setIsDisliked(false);
    }
    setIsLiked(!isLiked);

    try {
      await toggleReviewLike(review.id, !isLiked);
    } catch (error) {
      toast.error("Failed to update like");
    }
  };

  const handleDislike = async () => {
    if (isLiked) {
      setIsLiked(false);
    }
    setIsDisliked(!isDisliked);

    try {
      await toggleReviewDislike(review.id, !isDisliked);
    } catch (error) {
      toast.error("Failed to update dislike");
    }
  };

  const handleFlag = async () => {
    try {
      await flagReview(review.id);
      toast.success("Review flagged for moderation");
    } catch (error) {
      toast.error("Failed to flag review");
    }
  };

  const formatDate = (date: string) => {
    return new Date(date).toLocaleDateString("id-ID", {
      year: "numeric",
      month: "long",
      day: "numeric",
    });
  };

  return (
    <div className="bg-white rounded-lg p-6 border hover:shadow-md transition-shadow">
      {/* Review Header */}
      <div className="flex items-start justify-between mb-4">
        <div className="flex items-center space-x-3">
          <div className="w-10 h-10 bg-blue-100 rounded-full flex items-center justify-center">
            <span className="text-blue-600 font-semibold">
              {review.is_anonymous
                ? "A"
                : review.user.name.charAt(0).toUpperCase()}
            </span>
          </div>
          <div>
            <div className="font-medium text-gray-900">
              {review.is_anonymous ? "Anonymous" : review.user.name}
            </div>
            <div className="text-sm text-gray-500">
              {formatDate(review.created_at)}
            </div>
          </div>
        </div>

        <div className="flex items-center space-x-2">
          <StarRating rating={review.overall_rating} readonly size="sm" />
          <span className="text-sm text-gray-600">
            ({review.overall_rating}/5)
          </span>
        </div>
      </div>

      {/* Component Ratings */}
      {review.component_ratings && (
        <div className="grid grid-cols-2 md:grid-cols-4 gap-2 mb-4">
          {Object.entries(review.component_ratings).map(([key, value]) => (
            <div
              key={key}
              className="flex items-center justify-between text-sm"
            >
              <span className="text-gray-600 capitalize">{key}</span>
              <StarRating rating={value} readonly size="sm" />
            </div>
          ))}
        </div>
      )}

      {/* Review Text */}
      {review.review_text && (
        <div className="mb-4">
          <p className="text-gray-700 leading-relaxed">{review.review_text}</p>
        </div>
      )}

      {/* Review Actions */}
      <div className="flex items-center justify-between pt-4 border-t">
        <div className="flex items-center space-x-4">
          <button
            onClick={handleLike}
            className={`flex items-center space-x-1 text-sm ${
              isLiked ? "text-blue-600" : "text-gray-500 hover:text-blue-600"
            }`}
          >
            <ThumbsUp className="w-4 h-4" />
            <span>{review.likes_count + (isLiked ? 1 : 0)}</span>
          </button>

          <button
            onClick={handleDislike}
            className={`flex items-center space-x-1 text-sm ${
              isDisliked ? "text-red-600" : "text-gray-500 hover:text-red-600"
            }`}
          >
            <ThumbsDown className="w-4 h-4" />
            <span>{review.dislikes_count + (isDisliked ? 1 : 0)}</span>
          </button>

          <button
            onClick={() => setShowReply(!showReply)}
            className="flex items-center space-x-1 text-sm text-gray-500 hover:text-gray-700"
          >
            <Reply className="w-4 h-4" />
            <span>Reply</span>
          </button>
        </div>

        <button
          onClick={handleFlag}
          className="flex items-center space-x-1 text-sm text-gray-500 hover:text-red-600"
        >
          <Flag className="w-4 h-4" />
          <span>Flag</span>
        </button>
      </div>

      {/* Reply Section */}
      {showReply && (
        <div className="mt-4 pt-4 border-t">
          <div className="space-y-2">
            <textarea
              placeholder="Write a reply..."
              className="w-full px-3 py-2 border rounded-md resize-none"
              rows={2}
            />
            <div className="flex justify-end space-x-2">
              <button
                onClick={() => setShowReply(false)}
                className="px-3 py-1 text-sm text-gray-600 hover:text-gray-800"
              >
                Cancel
              </button>
              <button className="px-3 py-1 text-sm bg-blue-600 text-white rounded-md hover:bg-blue-700">
                Reply
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
```

### Rating Analytics Component

```typescript
import { useRatingAnalytics } from "@/hooks/useRatingAnalytics";
import { LineChart, BarChart, PieChart, ResponsiveContainer } from "recharts";

interface RatingAnalyticsProps {
  serviceType: "pool" | "cafe" | "staff" | "facility";
  serviceId: string;
  dateRange: { start: Date; end: Date };
}

export const RatingAnalytics = ({
  serviceType,
  serviceId,
  dateRange,
}: RatingAnalyticsProps) => {
  const { analytics, isLoading } = useRatingAnalytics({
    serviceType,
    serviceId,
    dateRange,
  });

  if (isLoading) {
    return <div className="animate-pulse h-64 bg-gray-200 rounded-lg"></div>;
  }

  return (
    <div className="space-y-6">
      {/* Overview Stats */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <div className="bg-white rounded-lg p-6 border">
          <div className="text-2xl font-bold text-blue-600">
            {analytics.averageRating}
          </div>
          <div className="text-sm text-gray-600">Average Rating</div>
        </div>
        <div className="bg-white rounded-lg p-6 border">
          <div className="text-2xl font-bold text-green-600">
            {analytics.totalReviews}
          </div>
          <div className="text-sm text-gray-600">Total Reviews</div>
        </div>
        <div className="bg-white rounded-lg p-6 border">
          <div className="text-2xl font-bold text-yellow-600">
            {analytics.positivePercentage}%
          </div>
          <div className="text-sm text-gray-600">Positive Reviews</div>
        </div>
        <div className="bg-white rounded-lg p-6 border">
          <div className="text-2xl font-bold text-purple-600">
            {analytics.responseRate}%
          </div>
          <div className="text-sm text-gray-600">Response Rate</div>
        </div>
      </div>

      {/* Rating Distribution */}
      <div className="bg-white rounded-lg p-6 border">
        <h3 className="text-lg font-semibold mb-4">Rating Distribution</h3>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div>
            <BarChart
              width={300}
              height={200}
              data={analytics.ratingDistribution}
            >
              <Bar dataKey="count" fill="#3b82f6" />
            </BarChart>
          </div>
          <div>
            <PieChart width={300} height={200}>
              <Pie
                data={analytics.ratingDistribution}
                dataKey="count"
                nameKey="rating"
                cx="50%"
                cy="50%"
                outerRadius={80}
                fill="#8884d8"
              />
            </PieChart>
          </div>
        </div>
      </div>

      {/* Rating Trends */}
      <div className="bg-white rounded-lg p-6 border">
        <h3 className="text-lg font-semibold mb-4">Rating Trends Over Time</h3>
        <ResponsiveContainer width="100%" height={300}>
          <LineChart data={analytics.ratingTrends}>
            <Line
              type="monotone"
              dataKey="averageRating"
              stroke="#3b82f6"
              strokeWidth={2}
            />
            <XAxis dataKey="date" />
            <YAxis domain={[0, 5]} />
            <Tooltip />
          </LineChart>
        </ResponsiveContainer>
      </div>

      {/* Component Ratings */}
      <div className="bg-white rounded-lg p-6 border">
        <h3 className="text-lg font-semibold mb-4">Component Ratings</h3>
        <div className="space-y-4">
          {analytics.componentRatings.map((component) => (
            <div
              key={component.name}
              className="flex items-center justify-between"
            >
              <span className="font-medium capitalize">{component.name}</span>
              <div className="flex items-center space-x-2">
                <StarRating
                  rating={component.averageRating}
                  readonly
                  size="sm"
                />
                <span className="text-sm text-gray-600">
                  {component.averageRating.toFixed(1)}/5
                </span>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Top Keywords */}
      <div className="bg-white rounded-lg p-6 border">
        <h3 className="text-lg font-semibold mb-4">Top Keywords</h3>
        <div className="flex flex-wrap gap-2">
          {analytics.topKeywords.map((keyword) => (
            <span
              key={keyword.word}
              className="px-3 py-1 bg-blue-100 text-blue-800 rounded-full text-sm"
            >
              {keyword.word} ({keyword.count})
            </span>
          ))}
        </div>
      </div>
    </div>
  );
};
```

## 📱 Mobile Optimization

### Responsive Rating Interface

```typescript
export const ResponsiveRatingInterface = () => {
  const isMobile = useMediaQuery("(max-width: 768px)");

  return (
    <div className={`rating-interface ${isMobile ? "mobile" : "desktop"}`}>
      {isMobile ? <MobileRatingInterface /> : <DesktopRatingInterface />}
    </div>
  );
};
```

## 🔄 State Management

### Rating Store (Zustand)

```typescript
import { create } from "zustand";

interface RatingState {
  ratings: Rating[];
  reviews: Review[];
  currentRating: Rating | null;
  isLoading: boolean;

  fetchRatings: (serviceType: string, serviceId: string) => Promise<void>;
  submitRating: (ratingData: RatingFormData) => Promise<Rating>;
  updateRating: (id: string, data: Partial<Rating>) => Promise<void>;
  deleteRating: (id: string) => Promise<void>;
  likeReview: (reviewId: string) => Promise<void>;
  flagReview: (reviewId: string) => Promise<void>;
}

export const useRatingStore = create<RatingState>((set, get) => ({
  ratings: [],
  reviews: [],
  currentRating: null,
  isLoading: false,

  fetchRatings: async (serviceType, serviceId) => {
    set({ isLoading: true });
    try {
      const response = await fetch(
        `/api/ratings?service_type=${serviceType}&service_id=${serviceId}`
      );
      const data = await response.json();
      set({ ratings: data.ratings, reviews: data.reviews });
    } catch (error) {
      console.error("Failed to fetch ratings:", error);
    } finally {
      set({ isLoading: false });
    }
  },

  submitRating: async (ratingData) => {
    const response = await fetch("/api/ratings", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(ratingData),
    });

    const rating = await response.json();
    set((state) => ({ ratings: [rating, ...state.ratings] }));
    return rating;
  },

  updateRating: async (id, data) => {
    const response = await fetch(`/api/ratings/${id}`, {
      method: "PUT",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(data),
    });

    const updatedRating = await response.json();
    set((state) => ({
      ratings: state.ratings.map((r) => (r.id === id ? updatedRating : r)),
    }));
  },

  deleteRating: async (id) => {
    await fetch(`/api/ratings/${id}`, {
      method: "DELETE",
    });

    set((state) => ({
      ratings: state.ratings.filter((r) => r.id !== id),
    }));
  },

  likeReview: async (reviewId) => {
    const response = await fetch(`/api/reviews/${reviewId}/like`, {
      method: "POST",
    });

    const updatedReview = await response.json();
    set((state) => ({
      reviews: state.reviews.map((r) =>
        r.id === reviewId ? updatedReview : r
      ),
    }));
  },

  flagReview: async (reviewId) => {
    await fetch(`/api/reviews/${reviewId}/flag`, {
      method: "POST",
    });
  },
}));
```

## 🧪 Testing

### Rating Component Testing

```typescript
import { render, screen, fireEvent, waitFor } from "@testing-library/react";
import { StarRating } from "@/components/rating/StarRating";
import { RatingForm } from "@/components/rating/RatingForm";

describe("Rating Components", () => {
  it("renders star rating with correct number of stars", () => {
    render(<StarRating rating={3} readonly />);

    const stars = screen.getAllByRole("button");
    expect(stars).toHaveLength(5);
  });

  it("allows rating selection when not readonly", () => {
    const mockOnRatingChange = jest.fn();
    render(<StarRating rating={0} onRatingChange={mockOnRatingChange} />);

    const thirdStar = screen.getAllByRole("button")[2];
    fireEvent.click(thirdStar);

    expect(mockOnRatingChange).toHaveBeenCalledWith(3);
  });

  it("submits rating form successfully", async () => {
    const mockOnSuccess = jest.fn();
    render(
      <RatingForm serviceType="pool" serviceId="1" onSuccess={mockOnSuccess} />
    );

    // Set overall rating
    const thirdStar = screen.getAllByRole("button")[2];
    fireEvent.click(thirdStar);

    // Fill review text
    const reviewText = screen.getByPlaceholderText("Share your experience...");
    fireEvent.change(reviewText, { target: { value: "Great experience!" } });

    // Submit form
    const submitButton = screen.getByRole("button", { name: /submit rating/i });
    fireEvent.click(submitButton);

    await waitFor(() => {
      expect(mockOnSuccess).toHaveBeenCalled();
    });
  });

  it("displays review list with ratings", () => {
    const mockReviews = [
      {
        id: "1",
        overall_rating: 5,
        review_text: "Excellent service!",
        user: { name: "John Doe" },
        created_at: "2024-01-01",
        is_anonymous: false,
      },
    ];

    render(<ReviewList reviews={mockReviews} />);

    expect(screen.getByText("John Doe")).toBeInTheDocument();
    expect(screen.getByText("Excellent service!")).toBeInTheDocument();
  });
});
```

## ✅ Success Criteria

- [ ] Star rating interface berfungsi dengan baik
- [ ] Review submission form responsif
- [ ] Review display interface terimplementasi
- [ ] Rating analytics dapat diakses
- [ ] Review moderation berjalan
- [ ] Mobile optimization terpasang
- [ ] Rating validation berfungsi
- [ ] Review filtering dan sorting berjalan
- [ ] Testing coverage > 85%

## 📚 Documentation

- Rating System Guide
- Review Management Guide
- Analytics Dashboard Guide
- Moderation Interface Guide
- Mobile Optimization Guide
